$(document).ready(function () {
  $(".modal").on('hidden.bs.modal', function() {
    $(this).find(".agenda-container").remove();
    $(this).data('bs.modal', null);
  });
});
