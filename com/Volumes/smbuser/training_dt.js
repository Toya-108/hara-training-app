
//timer
$(function(){

  
  var start_datetime = $("#start_datetime").val(); //試験開始時間を取得
  var loadDate = new Date(); //読み込まれた時間を取得
  var startDate = new Date(start_datetime);
  var diffMilliSec = loadDate - startDate;
  var diffSeconds = parseInt(diffMilliSec / 1000);

  var time_mesure_flag = $("#time_mesure_flag").val();
  if(time_mesure_flag == 1){ //時間計測あり
    var minutes = $("#time_limit").val(); // 1で1分
    //制限時間を秒に変換
    var seconds = minutes * 60;

    //経過時間を引く
    var leftSeconds = seconds - diffSeconds;
    var leftMinutes = leftSeconds / 60;
    var minutes = leftMinutes;

  }

  var dafa_time = (minutes * 60);
  var time = dafa_time;
  var interval;
  var min;
  var sec;

  if(time_mesure_flag == 1){
    init();
  } else {
    $("#timer_dip").hide();
  }

  function init() {
    min = Math.floor( time / 60 );
    sec = time % 60;
    min = ('00' + min).slice(-2);
    sec = ('00' + sec).slice(-2);
    $('#timer').html(min + ":" + sec);
    interval = setInterval(startTimer,1000);
  }

  function startTimer() {
    time --;
    if (time === 0 ) {
      $('#timer').html("TIME UP!!").css("color","red");
      clearInterval(interval);

      const training_code = $("#selected_training_code").val();
      const result_no = $("#result_no").val();

      var data = {
        training_code:training_code,
        result_no:result_no,
      }

      $.ajax({
        url: 'training_dt.cfc?method=insTimeupResultDetail',
        type: 'POST',
        dataType: "json",
        data: data
      })
      .done(function(result) {

        if(result.status == 0){

          $.ajax({
            url: 'training_dt.cfc?method=UpdResult',
            type: 'POST',
            dataType: "json",
            data: data
          })
          .done(function(result) {

            if(result.status == 0){
              document.master_form.target = "_self";
              document.master_form.method = "post";
              document.master_form.action = "result.cfm";
              document.master_form.submit();                  
            } else {
              $(".p-operation-btn").removeClass("p-disabled-btn").addClass("p-enabled-btn");
              alert(result.message);
            }

          })
          .fail(function() {
            $(".p-operation-btn").removeClass("p-disabled-btn").addClass("p-enabled-btn");
          })

        } else {
          $(".p-operation-btn").removeClass("p-disabled-btn").addClass("p-enabled-btn");
          alert(result.message);                    
        }

      })
      .fail(function() {
        $(".p-operation-btn").removeClass("p-disabled-btn").addClass("p-enabled-btn");
      })

    } else {
      calc();
    }
  }

  function resetTimer() {
    time = dafa_time;
    calc();
  }

  function calc() {
    min = Math.floor( time / 60 );
    sec = time % 60;
    min = ('00' + min).slice(-2);
    sec = ('00' + sec).slice(-2);
    $('#timer').html(min + ":" + sec);
    // $('#time_limit_now').val(min + ":" + sec);
  }

});



  $(document).ready(function(){
    $(".p-operation-btn").removeClass("p-disabled-btn").addClass("p-enabled-btn");

    $(".btn").on("click",function(){

      if($(this).hasClass("btn-preview")){
        var dest_question_number = parseInt($("#question_number").val()) - 1;
      } else if($(this).hasClass("btn-next")){
        var dest_question_number = parseInt($("#question_number").val()) + 1;
      }
      moveQuestion(dest_question_number);

    });

    function moveQuestion(dest_question_number) {
      const edit_flag = $("#edit_flag").val();
      const training_code = $("#selected_training_code").val();
      // var next_question_number = parseInt($("#question_number").val()) + 1;
      var next_question_number = dest_question_number;
      const seq_no = $("#question_number").val();
      const correct_answer_num = $("#correct_answer_num").val();
      const total_question_num = $("#total_question_num").val();
      const result_no = $("#result_no").val();
      const option_order = $("#option_no_list").val();
      var cnt_checked = 0; 
      var datas = $('.p-option').map(function(i){
        if($(this).prop('checked')){
          cnt_checked++;
          return $(this).val();
        }
      }).get().join('|');
      if(cnt_checked > correct_answer_num){ return;} //選択数が多い場合のみ

      if(next_question_number > total_question_num){
        var msg = "試験を終了します。よろしいですか？",
        cfm = confirm(msg);
        if(!cfm){
          return;
        }        
      }


      var data = {
        training_code:training_code,
        question_code:seq_no,
        result_no:result_no,
        seq_no:seq_no,
        answer:datas,
        option_order:option_order
      }


      if(edit_flag == 0){
        var url = 'training_dt.cfc?method=InsResultDetail';
      } else if(edit_flag == 1){
        var url = 'training_dt.cfc?method=UpdResultDetail';
      }

      $.ajax({
        url: url,
        type: 'POST',
        dataType: "json",
        data: data
      })
      .done(function(result) {
        if(result.status == 0){          
          if(seq_no != total_question_num || next_question_number < total_question_num){
            $("#question_number").val(next_question_number);
            document.master_form.target = "_self";
            document.master_form.method = "post";
            document.master_form.action = "training_dt.cfm";
            document.master_form.submit();                            
          } else {
            //最終問題である場合は、結果画面へ
            //ここで、t_tr_resultの終了時間とかを更新する。
            $.ajax({
              url: 'training_dt.cfc?method=UpdResult',
              type: 'POST',
              dataType: "json",
              data: data
            })
            .done(function(result) {

              if(result.status == 0){
                document.master_form.target = "_self";
                document.master_form.method = "post";
                document.master_form.action = "result.cfm";
                document.master_form.submit();                  
              }

            })
            .fail(function() {
              $(".p-operation-btn").removeClass("p-disabled-btn").addClass("p-enabled-btn");
            })
          }
        } else {
          $(".p-operation-btn").removeClass("p-disabled-btn").addClass("p-enabled-btn");
          alert(result.message);
        }
      })
      .fail(function() {
        $(".p-operation-btn").removeClass("p-disabled-btn").addClass("p-enabled-btn");
      })
    }


    $(".jss12").on("click",function(){

      var correct_answer_num = $("#correct_answer_num").val();
      var cnt_checked = 0; 
      var datas = $('.p-option').map(function(i){
        if($(this).prop('checked')){
          cnt_checked++;
          return $(this).val();
        }
      }).get().join('|');

      if($(this).prop("checked")){
        //checkする
        $(this).parent().parent().addClass('jss10 Mui-checked');
        $(this).next().css('color', '');
        $(this).next().css('font-size', '20px');
        $(this).next().css('background', '');
        $(this).next().css('border-radius', '');
        var id = $(this).next().children().attr('id');
        var path = document.getElementById(id);
        path.setAttribute('d','M19 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.11 0 2-.9 2-2V5c0-1.1-.89-2-2-2zm-9 14l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z');

      } else {
        //check解除
        $(this).parent().parent().removeClass('jss10 Mui-checked');
        $(this).next().css('color', '#e8e9eb');
        $(this).next().css('font-size', '18px');
        $(this).next().css('background', '#e8e9eb');
        $(this).next().css('border-radius', '4px');
        var id = $(this).next().children().attr('id');
        var path = document.getElementById(id);
        path.setAttribute('d','M19 5v14H5V5h14m0-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z');

      }

      if(cnt_checked > correct_answer_num){
        $(".info").show();
      } else if(cnt_checked <= correct_answer_num) {
        $(".info").hide();          
      }

    });


    // $("#move_on_").on("click",function(){
    //   const edit_flag = $("#edit_flag").val();
    //   const training_code = $("#selected_training_code").val();
    //   var next_question_number = parseInt($("#question_number").val()) + 1;
    //   const seq_no = $("#question_number").val();
    //   const correct_answer_num = $("#correct_answer_num").val();

    //   //現在の問題数と全体の問題数
    //   const total_question_num = $("#total_question_num").val();

    //   const result_no = $("#result_no").val();
    //   var cnt_checked = 0; 
    //   var datas = $('.p-option').map(function(i){
    //     if($(this).prop('checked')){
    //       cnt_checked++;
    //       return $(this).val();
    //     }
    //   }).get().join('|');
    //   if(cnt_checked > correct_answer_num){ return;} //選択数が多い場合のみ

    //   var data = {
    //     training_code:training_code,
    //     question_code:seq_no,
    //     result_no:result_no,
    //     seq_no:seq_no,
    //     answer:datas
    //   }


    //   if(edit_flag == 0){
    //     var url = 'training_dt.cfc?method=InsResultDetail';
    //   } else if(edit_flag == 1){
    //     var url = 'training_dt.cfc?method=UpdResultDetail';
    //   }

    //   $.ajax({
    //     url: url,
    //     type: 'POST',
    //     dataType: "json",
    //     data: data
    //   })
    //   .done(function(result) {
    //     if(result.status == 0){          
    //       if(seq_no != total_question_num){
    //         //最終問題でない場合は、次の問題へ
    //         $("#question_number").val(next_question_number);
    //         document.master_form.target = "_self";
    //         document.master_form.method = "post";
    //         document.master_form.action = "training_dt.cfm";
    //         document.master_form.submit();                            
    //       } else {
    //         //最終問題である場合は、結果画面へ
    //         //ここで、t_tr_resultの終了時間とかを更新する。
    //         $.ajax({
    //           url: 'training_dt.cfc?method=UpdResult',
    //           type: 'POST',
    //           dataType: "json",
    //           data: data
    //         })
    //         .done(function(result) {

    //           if(result.status == 0){
    //             document.master_form.target = "_self";
    //             document.master_form.method = "post";
    //             document.master_form.action = "result.cfm";
    //             document.master_form.submit();                  
    //           }

    //         })
    //         .fail(function() {
    //           $(".p-operation-btn").removeClass("p-disabled-btn").addClass("p-enabled-btn");
    //         })
    //       }
    //     } else {
    //       $(".p-operation-btn").removeClass("p-disabled-btn").addClass("p-enabled-btn");
    //       alert(result.message);
    //     }
    //   })
    //   .fail(function() {
    //     $(".p-operation-btn").removeClass("p-disabled-btn").addClass("p-enabled-btn");
    //   })
    // });

    // $("#back_").on("click",function(){

    //   const correct_answer_num = $("#correct_answer_num").val();
    //   var cnt_checked = 0; 
    //   var datas = $('.p-option').map(function(i){
    //     if($(this).prop('checked')){
    //       cnt_checked++;
    //       return $(this).val();
    //     }
    //   }).get().join('|');

    //   if(cnt_checked > correct_answer_num){ return;} //選択数が多い場合のみ

    //   var question_number = parseInt($("#question_number").val()) - 1;
    //   $("#question_number").val(question_number);
    //   document.master_form.target = "_self";
    //   document.master_form.method = "post";
    //   document.master_form.action = "training_dt.cfm";
    //   document.master_form.submit();                  
    // });


  })
