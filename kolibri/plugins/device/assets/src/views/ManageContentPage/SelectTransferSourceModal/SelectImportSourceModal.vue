<template>

  <SelectSourceModal
    :submitDisabled="formIsDisabled"
    :showLoadingMessage="formIsDisabled && !initialDelay"
    @submit="handleSubmit"
    @cancel="handleCancel"
  >
    <KRadioButton
      v-model="source"
      :label="$tr('network')"
      :value="ContentSources.KOLIBRI_STUDIO"
      :disabled="kolibriStudioIsOffline || formIsDisabled"
      :autofocus="!kolibriStudioIsOffline"
      :description="$tr('studioDescription')"
    />
    <KRadioButton
      v-model="source"
      :label="$tr('localNetworkOrInternet')"
      :value="ContentSources.PEER_KOLIBRI_SERVER"
      :disabled="formIsDisabled"
      :description="$tr('networkDescription')"
    />
    <KRadioButton
      v-model="source"
      :label="$tr('localDrives')"
      :value="ContentSources.LOCAL_DRIVE"
      :disabled="formIsDisabled"
      :description="$tr('localDescription')"
    />
  </SelectSourceModal>

</template>


<script>

  import { mapActions, mapMutations } from 'vuex';
  import { RemoteChannelResource } from 'kolibri.resources';
  import { ContentSources } from '../../../constants';
  import SelectSourceModal from '../../SelectSourceModal';

  export default {
    name: 'SelectImportSourceModal',
    components: {
      SelectSourceModal,
    },
    data() {
      return {
        source: ContentSources.KOLIBRI_STUDIO,
        initialDelay: true, // hide everything for a second to prevent flicker
        formIsDisabled: true,
        kolibriStudioIsOffline: false,
        ContentSources,
      };
    },
    created() {
      setTimeout(() => {
        this.initialDelay = false;
      }, 1000);
      RemoteChannelResource.getKolibriStudioStatus().then(({ data }) => {
        if (data.status === 'offline') {
          this.source = ContentSources.PEER_KOLIBRI_SERVER;
          this.kolibriStudioIsOffline = true;
        }
        this.formIsDisabled = false;
      });
    },
    methods: {
      ...mapActions('manageContent/wizard', ['goForwardFromSelectImportSourceModal']),
      ...mapMutations('manageContent/wizard', {
        resetContentWizardState: 'RESET_STATE',
      }),
      handleSubmit() {
        if (!this.formIsDisabled) {
          if (this.$attrs.manageMode) {
            this.$emit('submit', { source: this.source });
          } else {
            this.goForwardFromSelectImportSourceModal(this.source);
          }
        }
      },
      handleCancel() {
        if (this.$attrs.manageMode) {
          this.$emit('cancel');
        } else {
          this.resetContentWizardState();
        }
      },
    },
    $trs: {
      network: 'Kolibri Studio (online)',
      localNetworkOrInternet: 'Local network or internet',
      localDrives: 'Attached drive or memory card',
      studioDescription:
        'Import resources from Kolibri Studio if you are connected to the internet',
      networkDescription:
        'Import resources from another instance of Kolibri running on another device, either in the same local network or on the internet',
      localDescription:
        'Import resources from a drive. Channels must have first been exported onto the drive from another instance of Kolibri',
    },
  };

</script>


<style lang="scss" scoped></style>
