<template>
  <div class="flex-wrap-column" v-if="panelFigures && content">
    <draggable v-model="depictions" :options="{ filter:'.dropzone-card', handle: '.card-handle' }" @start="drag=true" @end="drag=false, updatePosition()" class="item item1 column-medium flex-wrap-row">
      <figure-item v-for="item in depictions" :figure="item" :key="item.id"></figure-item>
      <dropzone class="dropzone-card" v-on:vdropzone-sending="sending" v-on:vdropzone-success="success" ref="figure" id="figure" url="/depictions" :useCustomDropzoneOptions="true" :dropzoneOptions="dropzone"></dropzone>
    </draggable>
    <div class="item item2 column-tiny no-margin">
    </div>
  </div>
</template>
<script>

  const draggable = require('vuedraggable');
  const dropzone = require('../../../components/dropzone.vue').default;
  const figureItem = require('./figureItem.vue').default;
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;
  var token = $('[name="csrf-token"]').attr('content');

  export default {
      computed: {
        content() {
          return this.$store.getters[GetterNames.GetContentSelected]
        },
        panelFigures() {
          return this.$store.getters[GetterNames.PanelFigures]
        },
        depictions: {
            get() {
                return this.$store.getters[GetterNames.GetDepictionsList]
            },
            set(value) {
                this.$store.commit(MutationNames.SetDepictionsList, value)
            }
        }        
      },
      components: {
        draggable: draggable,
        dropzone,
        figureItem
      },
      data: function() {
        return {
          drag: false,
          dropzone: {
            paramName: "depiction[image_attributes][image_file]",
            url: "/depictions",
            headers: {
              'X-CSRF-Token' : token
            },
            dictDefaultMessage: "Drop images here to add figures",
            acceptedFiles: "image/*"
          },             
        }
      },
      watch: {
        'content': function(val, oldVal) {
          if(val != undefined) {
            if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
              this.loadContent();
            }
          }
          else {
            this.$store.commit(MutationNames.SetDepictionsList, []);
          }
        }
      },
      methods: {
        'success': function(file, response) {
          this.$store.commit(MutationNames.AddDepictionToList, response);
          this.$refs.figure.removeFile(file);
        },
        'sending': function(file, xhr, formData) {
          formData.append("depiction[depiction_object_id]", this.content.id);
          formData.append("depiction[depiction_object_type]", "Content");
        },
        loadContent: function() {
          var ajaxUrl = `/contents/${this.content.id}/depictions.json`;
          this.$http.get(ajaxUrl).then( response => {
            this.$store.commit(MutationNames.SetDepictionsList, response.body);
          });
        },
        updatePosition: function() {
          var ajaxUrl = `/depictions/sort`,
              array =  {
              depiction_ids: []
            };

          this.depictions.forEach( function(item) {
              array.depiction_ids.push(item.id);
          });
          this.$http.patch(ajaxUrl,array).then( response => {
          });
        }
      }  
  };
</script>