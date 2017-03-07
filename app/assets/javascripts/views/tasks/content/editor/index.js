var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.content = TW.views.tasks.content || {};
TW.views.tasks.content.editor = TW.views.tasks.content.editor || {};


Object.assign(TW.views.tasks.content.editor, {

  init: function() { 

    // JOSE - we can make this more generalized I think, but this works
    Vue.http.headers.common['X-CSRF-Token'] = $('[name="csrf-token"]').attr('content');

    const store = new Vuex.Store({
      state: {    
        selected: {
          topic: undefined,
          otu: undefined
        },
        panels: {
          otu: false,
          topic: true,
          recent: true
        }
      },
      getters: {
        activeTopicPanel(state) {          
          return state.panels.topic
        },
        activeOtuPanel(state) {
          return state.panels.otu
        },
        activeRecentPanel(state) {
          return state.panels.recent
        },        
        getTopicSelected(state) {
          return state.selected.topic
        },
        getOtuSelected(state) {
          return state.selected.otu
        }        
      },
      mutations: {
        setTopicSelected(state, newTopic) {
          state.selected.topic = newTopic;
        },
        setOtuSelected(state, newOtu) {
          state.selected.otu = newOtu;
        },
        setContentSelected(state, newContent) {
          state.selected.otu = newContent.otu;
          state.selected.topic = newContent.topic;
        },        
        openOtuPanel(state, value) {
          state.panels.otu = value;
        },
        openTopicPanel(state, value) {
          state.panels.topic = value;
        },     
        openRecentPanel(state, value) {
          state.panels.recent = value;
        }        
      }
    });

    Vue.component('itemOption', {
      props: ['name', 'callMethod'],
      data: function() { 
        return {
          disabled: false
        }
      },
      template: '<div v-if="!disabled" class="navigation-item" v-on:click="action">{{ name }}</div>',
      methods: {
        action: function (){
          if(!this.disabled && this.callMethod !== undefined) {
            this.callMethod()
          }
        }
      }
    });  

    Vue.component('citation-list', {
      props: ['citations'],
      template: '<ul v-if="citations.length > 0"> \
                  <li class="flex-separate middle" v-for="item, index in citations">{{ item.source.author_year }} <div @click="removeItem(index, item)" class="circle-button btn-delete">Remove</div> </li> \
                </ul>',

      methods: {
        removeItem: function(index, item) {
          this.$http.delete("/citations/"+item.id).then( response => {
            this.citations.splice(index,1);
          });
        }
      }
    });

    Vue.component('recent-list', {
      props: { url: String, nameList: String, saveState: String, label: String, objects: {
        type: Array,
        default: function() { return [] }
      }} ,
      data: function() {
        return {
          items: [],
        }
      },
      template: '<div> \
                  <div class="slide-panel-category-header"> {{ nameList }}</div> \
                    <ul class="slide-panel-category-content"> \
                      <li v-for="item in items" v-on:click="save(item)" class="slide-panel-category-item"><span v-html="createString(item)"></span></li> \
                    </ul> \
                  </div> \
                </div>',
      
      mounted: function() {
        this.$http.get(this.url).then( response => {
          this.items = response.body;
        }); 
      },
      methods: {
        save: function(item) {
          this.$store.commit(this.saveState, item);
          this.$store.commit('openOtuPanel', true);
        },
        createString: function(item) {
          if (this.objects.length < 1) return item[this.label];

          var resultString = '',
              that = this;
          this.objects.forEach(function(object, index) {
            resultString += item[object][that.label] + " ";
          });
          return resultString;
        }
      }
    });    

    Vue.component('recent', {
      template: '<div id="recent-list" class="slide-panel slide-recent " data-panel-open="false" data-panel-name="recent_list"> \
                  <div class="slide-panel-header">Recent list</div> \
                  <div class="slide-panel-content"> \
                    <recent-list url="/contents.json" name-list="Contents" saveState="setContentSelected" v-bind:objects="[\'topic\', \'otu\']" label="object_tag"></recent-list> \
                    <recent-list url="/tasks/content/editor/recent_topics.json?" name-list="Topics" saveState="setTopicSelected" label="name"></recent-list> \
                    <recent-list url="/tasks/content/editor/recent_otus.json" name-list="OTUs" saveState="setOtuSelected" label="name"></recent-list> \
                  </div> \
                  <div class="slide-panel-circle-icon"> \
                    <div class="slide-panel-description">Recent created</div> \
                  </div> \
                  </div> \
                </div>',
      mounted: function() {
      //  TW.views.shared.slideout.closeHideSlideoutPanel('[data-panel-name="recent_list"]');
      }
    });      

    Vue.component('citation-modal', {
      template: '<div class="panel content"> \
                  <span>Source ID: {{ citation.source_id }} </span> \
                  <input class="normal-input" placeholder="Pages" v-model="citation.pages"/> \
                </div>',
      data: function() {
        return {
          citation: {
            pages: '',
            source_id: '',
            citation_object_type: null,
            citation_object_id: null,
            is_original: null
          } 
        }
      }
    });


    Vue.component('content-editor', {
      data: function() { 
        return {
          autosave: 0,
          unsave: false,
          citationModal: false,
          citations: [],
          currentSourceID: '',
          newRecord: true,
          record: { 
            content: {
              otu_id: '',
              topic_id: '',
              text: '',
            }
          }
        }
      },
      computed: {
        topic() {
          return this.$store.getters.getTopicSelected
        },
        otu() {
          return this.$store.getters.getOtuSelected
        }          
      },      
      template: '<div v-if="topic !== undefined && otu !== undefined" class="panel panel-editor separate-left separate-right"> \
                  <div class="title action-line">{{ topic.name }} - {{ otu.name }} </div> \
                  <textarea v-on:input="autoSave" v-model="record.content.text" ref="contentText" v-on:dblclick="addCitation()"></textarea> \
                  <div class="navigation-controls horizontal-center-content"> \
                    <itemOption name="Save" :callMethod="update" :class="{ saving : unsave }"></itemOption> \
                    <itemOption name="Preview"></itemOption> \
                    <itemOption name="Help"></itemOption> \
                    <itemOption name="Clone"></itemOption> \
                    <itemOption name="Compare"></itemOption> \
                    <itemOption name="Citation" :callMethod="openCitation"></itemOption> \
                    <itemOption name="Figure"></itemOption> \
                    <itemOption name="Drag new figure"></itemOption> \
                  </div> \
                  <citation-modal v-if="citationModal"></citation-modal> \
                  <citation-list :citations="citations" class="citation-list"></citation-list> \
                </div>',
      watch: {
        otu: function(val, oldVal) {
          if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
            this.loadContent();
          }
        },
        topic: function(val, oldVal) {
          if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
            this.loadContent();
          }
        }            
      },
      methods: {
        existCitation: function(citation) {
          var exist = false;
          this.citations.forEach(function(item, index) {

          if(item['source_id'] == citation.source_id) {
              exist = true;
            }
          }); 
          return exist;
        },

        addCitation: function(datas) {

          var that = this;
          setTimeout(function(){
            that.record.content.text = that.$refs.contentText.value;
            if(that.newRecord) {
              var ajaxUrl = `/contents/${that.record.content.id}`;
              if(that.record.content.id == '') {
                that.$http.post(ajaxUrl, that.record).then(response => {
                  that.record.content.id = response.body.id;
                  that.newRecord = false;
                  that.createCitation();
                 });            
              }
            }
            else {
              that.update();
              that.createCitation();
            }
          
        },100)},
        createCitation: function() {
          var
            sourcePDF = document.getElementById("pdfViewerContainer").dataset.sourceid;          
          if(sourcePDF == undefined) return
          
          this.currentSourceID = sourcePDF;          

          var citation = {
            pages: '',
            citation_object_type: 'Content',  
            citation_object_id: this.record.content.id,          
            source_id: this.currentSourceID
          }
          if(this.existCitation(citation)) return

          this.$http.post('/citations', citation).then(response => {
            this.citations.push(response.body);
          }, response => {

          });            
        },        

        openCitation: function() {
          this.citationModal = !this.citationModal;
        },

        autoSave: function() {
          var that = this;
          this.unsave = true;
          if(this.autosave) {
            clearTimeout(this.autosave);
            this.autosave = null
          }   
          this.autosave = setTimeout( function() {    
            that.update();  
          }, 5000);           
        },    

        update: function() {
          var ajaxUrl = `/contents/${this.record.content.id}`;

          if(this.record.content.id == '') {
            this.$http.post(ajaxUrl, this.record).then(response => {
              this.record.content.id = response.body.id;
              this.unsave = false;
             });            
          }
          else {
            this.$http.patch(ajaxUrl, this.record).then(response => {
              this.unsave = false;
             });
          }          
        },

        loadCitationList: function() {
          var ajaxUrl;

          ajaxUrl = `/contents/${this.record.content.id}/citations`;
          this.$http.get(ajaxUrl, this.record).then(response => {
            this.citations = response.body;
          }, response => {

          }); 
        },

        loadContent: function() {
          if(this.otu == undefined || this.topic == undefined) return

          var
            ajaxUrl = `/contents/filter.json?otu_id=${this.otu.id}&topic_id=${this.topic.id}`

          this.$http.get(ajaxUrl).then(response => {
            if(response.body.length > 0) {
              this.record.content.id = response.body[0].id;
              this.record.content.text = response.body[0].text;
              this.record.content.topic_id = response.body[0].topic_id;
              this.record.content.otu_id = response.body[0].otu_id;
              this.newRecord = false;
              this.loadCitationList();
            }
            else {
              this.record.content.text = '';
              this.record.content.id = '';              
              this.record.content.topic_id = this.topic.id;
              this.record.content.otu_id = this.otu.id;
              this.newRecord = true;
            }
          }, response => {
            // error callback
          });
        }
      }                
    });                 

    Vue.component('new-topic', {
      template: '<div> \
                  <button v-on:click="openWindow" class="button normal-input">New</button> \
                    <modal v-if="showModal" @close="showModal = false"> \
                      <h3 slot="header">New topic</h3> \
                      <form  id="new-topic" action="" slot="body"> \
                        <div class="field"> \
                          <input type="text" v-model="topic.controlled_vocabulary_term.name" placeholder="Name" /> \
                        </div> \
                        <div class="field"> \
                          <textarea v-model="topic.controlled_vocabulary_term.definition" placeholder="Definition"></textarea> \
                        </div> \
                      </form> \
                      <div slot="footer" class="flex-separate"> \
                        <input class="button normal-input" type="submit" v-on:click.prevent="createNewTopic" :disabled="((topic.controlled_vocabulary_term.name.length < 2) || (topic.controlled_vocabulary_term.definition.length < 2)) ? true : false" value="Create"/> \
                        <button class="button button-close normal-input" @click="showModal = false">Close</button> \
                      </div> \
                    </modal> \
                  <div>',
      data: function() { return {
        showModal: false,
        topic: {
          controlled_vocabulary_term: {
            name: '',
            definition: '',
            type: 'Topic'
            }
          }
        }
      },
      methods: {
        openWindow: function() {
          this.topic.controlled_vocabulary_term.name = '';
          this.topic.controlled_vocabulary_term.definition = '';
          this.showModal = true;          
        },
        createNewTopic: function() {
          var that = this;
          this.$http.post('/controlled_vocabulary_terms.json', this.topic).then( response => {
              TW.workbench.alert.create(response.body.name + " was successfully created.", "notice");
              that.$parent.topics.push(response.body);
          });
          this.showModal = false;
        }        
      }
    }); 

    Vue.component('topic-section', {
      template: '<div id="topics" class="slide-panel slide-left" v-if="active" data-panel-open="false" data-panel-name="topic_list"> \
                  <div class="slide-panel-header flex-separate">Topic list<new-topic></new-topic></div> \
                  <div class="slide-panel-content"> \
                    <div class="slide-panel-category"> \
                      <ul class="slide-panel-category-content"> \
                        <li v-for="item, index in topics" class="slide-panel-category-item" :class="{ selected : (index == selected) }"v-on:click="loadTopic(item,index)"> {{ item.name }}</li> \
                      </ul> \
                    </div> \
                  </div> \
                  <div class="slide-panel-circle-icon"> \
                    <div class="slide-panel-description">Pinboard </div> \
                  </div> \
                </div>', 
      data: function() { 
        return {
          selected: -1,
          topics: []
        }
      },
      computed: {
        active() {
          return this.$store.getters.activeTopicPanel;
        }
      },
      mounted: function() {
        TW.views.shared.slideout.closeHideSlideoutPanel('[data-panel-name="recent_list"]');
        this.loadList();
      },
      methods: {
        loadTopic: function(item, index) {
          this.selected = index
          this.$store.commit('setTopicSelected', item);
          this.$store.commit('openOtuPanel', true);
          TW.views.shared.slideout.closeHideSlideoutPanel('[data-panel-name="topic_list"]');
        },       
        loadList: function() {
          var that;
          that = this;
          this.$http.get('/topics/list').then( response => {
            that.topics = response.body;
          });         
        }
      }
    });

    Vue.component('panel-top', {
      computed: {
        display() {
          return this.$store.getters.activeOtuPanel
        }
      },
      template: '<div v-if="display" id="otu_panel" class="panel content separate-bottom"> \
                  <autocomplete \
                    url="/otus/autocomplete" \
                    min="3" \
                    param="term" \
                    placeholder="Find OTU" \
                    event-send="otu_picker" \
                    label="label"> \
                  </autocomplete> \
                 </div>',
      mounted: function() {
        var that = this;
        this.$on('otu_picker', function (item) {
          that.$store.commit('setOtuSelected', item); 
        })                  
      }
    });

    var content_editor = new Vue({
      el: '#content_editor',
      store: store      
    });  
  }
});

$(document).ready( function() {
  if ($("#content_editor").length) {
    TW.views.tasks.content.editor.init();
  }
});


