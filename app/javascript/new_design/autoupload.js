import Uploader from '../shared/activestorage/uploader';
import { ajax, delegate, fire } from '@utils';

const fileInputSelector = `input[type=file][data-direct-upload-url][data-auto-upload]:not([disabled])`;

// Listen to files being attached to file inputs
delegate('change', fileInputSelector, (event) => {
  const input = event.target;
  Array.from(input.files).forEach(file => uploadFile(input, file));
});

async function uploadFile(input, file) {
  try {
    input.disabled = true;

    const champ = input.closest('.editable-champ[data-champ-id]');
    if (!champ) {
      throw new Error('[Autoupload] Could not find the parent .editable-champ');
    }
    const champId = champ.dataset.champId;

    const uploader = new Uploader(input, file, input.dataset.directUploadUrl);
    const blobSignedId = await uploader.start();

    // Now that the blob was uploaded, clear the original file input value
    input.value = nil;

    const autoAttachUrl = input.dataset.autoAttachUrl;
    if (autoAttachUrl) {
      // Attach the blob to the champ
      const params = {
        url: autoAttachUrl,
        type: 'PUT',
        data: new URLSearchParams({
          champ_id: champId,
          blob_signed_id: blobSignedId
        })
      };

      await ajax(params);
    }


  } catch (error) {
    // FIXME
    console.error(error);

  } finally {
    input.disabled = false;
  }
}
