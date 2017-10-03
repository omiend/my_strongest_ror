$(function(){

  var fileName;

  // 画像ファイル選択後のプレビュー処理
  $('form').on('change', 'input[type="file"]', function(event) {
    var file = event.target.files[0];
    fileName = file.name;
    var reader = new FileReader();
    var $crop_area_box = $('#crop_area_box');
    // 画像ファイル以外の場合は何もしない
    if(file.type.indexOf('image') < 0){
      return false;
    }
    // ファイル読み込みが完了した際のイベント登録
    reader.onload = (function(file) {
      return function(event) {
        //既存のプレビューを削除
        $crop_area_box.empty();
        // .prevewの領域の中にロードした画像を表示するimageタグを追加
        $crop_area_box.append($('<img>').attr({
          src: event.target.result,
          id: "crop_image",
          title: file.name
        }));
        // プレビュー処理に対して、クロップ出来る処理を初期化設定
        initCrop();
      };
    })(file);
    reader.readAsDataURL(file);
  });

  var cropper;
  function initCrop() {
    cropper = new Cropper(crop_image, {
      dragMode: 'move', // 画像を動かす設定
      aspectRatio: 1 / 1, // 正方形やで！
      restore: false,
      guides: false,
      center: false,
      highlight: false,
      cropBoxMovable: false,
      cropBoxResizable: false,
      toggleDragModeOnDblclick: false,
      minCropBoxWidth: 300,
      minCropBoxHeight: 300,
      ready: function () {
        croppable = true;
      }
    });
    // 初回表示時
    crop_image.addEventListener('ready', function(e){
      cropping(e);
    });
    // 画像をドラッグした際の処理
    crop_image.addEventListener('cropend', function(e){
      cropping(e);
    });
    // 画像を拡大・縮小した際の処理
    crop_image.addEventListener('zoom', function(e){
      cropping(e);
    });
  }

  // クロップ処理した画像をプレビュー領域に表示
  var croppedCanvas;
  function cropping(e) {
    croppedCanvas = cropper.getCroppedCanvas({
      width: 300,
      height: 300,
    });
    // `$('<img>'{src: croppedCanvas.toDataURL()});` 的に書きたかったけど、jQuery力が足りず・・・
    var croppedImage = document.createElement('img');
    croppedImage.src = croppedCanvas.toDataURL();
    crop_preview.innerHTML = '';
    crop_preview.appendChild(croppedImage);
  }

  // Submit時に実行するPOST処理
  $('#submitBtn').on('click', function(event){
    // クロップ後のファイルをblobに変換し、AjaxでForm送信
    croppedCanvas.toBlob(function (blob) {
      const fileOfBlob = new File([blob], fileName);
      var formData = new FormData();
      // `employee[avatar]` は `employee` modelに定義した `mount_uploader :avatar, AvatarUploader` のコト
      formData.append('employee[avatar]', fileOfBlob);
      // EmployeeのID取得
      const employee_id = $('#employee_id').val();
      $.ajax('/avatar/' + employee_id + '/update', {
        method: "PATCH", // POSTの方が良いのかな？
        data: formData,
        processData: false, // 余計な事はせず、そのままSUBMITする設定？
        contentType: false,
        success: function (res) {
          // DOM操作にしたほうがいいのかな？その場合、アップロード後に実行するなどのポーリング処理的なサムシングが必要になりそう・・・
          // なので、とりあえず簡単に`location.reload`しちゃう
          location.reload();
        },
        error: function (res) {
          console.error('Upload error');
        }
      });
    // S3にアップロードするため画質を50%落とす
    }, 'image/jpeg', 0.5);
  });

});
