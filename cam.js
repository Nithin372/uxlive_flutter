(function(){
    var video = document.getElementById('video'),
    vendorUrl = window.URL || window.webkitURL;

    navigator.getMedia({
        video: true,
        audio: false
    }, function(stream){
        video.src = vendorUrl.createObjectURL(stream);
        video.play();
    }, function(error){
        // An error Occured
        //error code
    }
    )

})();