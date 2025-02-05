import { FetchRequest } from '@rails/request.js'

function dragOverHandler(ev) {
  console.log("Entering the drop zone");

  // Prevent default behavior (Prevent file from being opened)
  ev.preventDefault();

  document.getElementById("drop_zone").style.background = "#999999";
}

function dragLeaveHandler(ev) {
  console.log("Leaving the drop zone");

  // Prevent default behavior (Prevent file from being opened)
  ev.preventDefault();

  document.getElementById("drop_zone").style.background = "";
}

async function create_new_file(type, file) {
  let formData = null;
  let post_location = null;
  if (type === "csv") {
    let form = document.getElementById("csv_file_form");
    formData = new FormData( form )
    formData.set( "csv_file[csvfile]", file, file.filename)
    post_location = `${window.location.origin}/certbot/csv_files`
    document.getElementById("drop_zone_txt").innerHTML = "Ανέβασμα CSV αρχείου"
  } else if (type === "odt" || type === "odp" || type === "ods" || type === "odg" ) {
    let form = document.getElementById("odf_file_form");
    formData = new FormData( form )
    formData.set("odt_file[odtfile]", file, file.filename)
    post_location = `${window.location.origin}/certbot/odt_files`
    document.getElementById("drop_zone_txt").innerHTML = `Ανέβασμα ${type} αρχείου`
  }

  if (formData != null) {
    console.log(`Working on ${file.name}`);
    console.log(`Posting to ${post_location}`);
    console.log( formData );
    document.getElementById("drop_zone_txt").classList.add("blink_me")

    const request = new FetchRequest('post', post_location, { body: formData });
    const response = await request.perform()
    if (response.ok) {
      const body = await response.text
      location.reload();
    } else {
      location.reload();
      console.log("Error occured while uploading file");
    }
    document.getElementById("drop_zone_txt").classList.remove("blink_me")
  }
}

function process_file( file ) {

  let extension = file.name.toLowerCase().split(".").pop();

  if (extension === "csv") {
    console.log('Detected CSV');
    create_new_file(extension, file);
  } else if (extension === "odp" || extension === "odt" || extension === "ods" || extension === "odg" ) {
    console.log('Detected ODF');
    create_new_file(extension, file);
  } else {
    console.log('File type not detected');
    document.getElementById("drop_zone").style.background = "red"
  }
}

function dropHandler(ev) {
  console.log("File(s) dropped");

  // Prevent default behavior (Prevent file from being opened)
  ev.preventDefault();

  if (ev.dataTransfer.items) {
    // Use DataTransferItemList interface to access the file(s)
    [...ev.dataTransfer.items].forEach((item, i) => {
      // If dropped items aren't files, reject them
      if (item.kind === "file") {
        const file = item.getAsFile();
        process_file( file );
      }
    });
  } else {
    // Use DataTransfer interface to access the file(s)
    [...ev.dataTransfer.files].forEach((file, i) => {
      process_file( file );
    });
  }
}


export { dragOverHandler, dragLeaveHandler, dropHandler }
