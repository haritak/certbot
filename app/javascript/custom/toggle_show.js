function toggleShow(class_element) {
  var x = document.getElementById(class_element);
  if (x.style.display === "none") {
        x.style.display = "block";
  } else {
        x.style.display = "none";
  }
}
