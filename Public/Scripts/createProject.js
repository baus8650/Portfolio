$.ajax({
  url: "/api/skills/",
  type: "GET",
  contentType: "application/json; charset=utf-8"
}).then(function (response) {
  var dataToReturn = [];
  for (var i=0; i < response.length; i++) {
    var tagToTransform = response[i];
    var newTag = {
                   id: tagToTransform["name"],
                   text: tagToTransform["name"]
                 };
    dataToReturn.push(newTag);
  }
  $("#skills").select2({
    placeholder: "Select Skills for the Project",
    tags: true,
    tokenSeparators: [','],
    data: dataToReturn
  });
});
