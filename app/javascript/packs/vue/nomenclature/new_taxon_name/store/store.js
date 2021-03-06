import Vue from 'vue';
import Vuex from 'vuex';

const getters = require('./getters/getters');
const mutations = require('./mutations/mutations');
const actions = require('./actions/actions');

Vue.use(Vuex);

function makeInitialState() {
  return {
    taxon_name: {
      id: undefined,
      global_id: undefined,
      parent_id: undefined,
      name: undefined,
      rank: undefined,
      rank_class: undefined,
      rank_string: undefined,
      year_of_publication: undefined,
      verbatim_author: undefined,
      feminine_name: undefined,
      masculine_name: undefined,
      neuter_name: undefined,
      origin_citation: undefined,
      taxon_name_author_roles: undefined,
      roles_attributes: [],
      etymology: ''
    },
    settings: {
      modalStatus: false,
      modalType: false,
      modalRelationship: false,
      saving: false,
      lastSave: 0,
      lastChange: 0
    },
    taxonStatusList: [],
    taxonRelationshipList: [],
    taxonRelationship: undefined,
    taxonType: undefined,
    softValidation: {
      taxon_name: {
        title: 'Taxon name',
        list: [],
      },
      taxonRelationshipList: {
        title: 'Relationships',
        list: [],
      },
      taxonStatusList: {
        title: 'Status',
        list: [],
      },
    },
    hardValidation: undefined,
    nomenclatural_code: undefined,
    parent: undefined,
    ranks: undefined,
    rankGroup: undefined,
    status: [],
    relationships: [],
    allRanks: [],
    original_combination: []
  };
}

function newStore() {
  return new Vuex.Store({
    state: makeInitialState(),
    getters: getters.GetterFunctions,
    mutations: mutations.MutationFunctions,
    actions: actions.ActionFunctions
  });
}

module.exports = {
  newStore
};
