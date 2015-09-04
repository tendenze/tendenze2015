function init() {
  var img_defer = $(".band .image img");
  for(var i = 0; i < img_defer.length; i++) {
    if(img_defer[i].getAttribute("data-src")) {
      img_defer[i].setAttribute("src", img_defer[i].getAttribute("data-src"));
    }
  };
}
window.onload = init;
