<#include "../layout/layout.ftl"/>
<@html page_title="设置" page_tab="settings">
  <div class="user">
    <div class="left menu">
      <ul>
        <li><a href="#baseDiv">基本信息</a></li>
        <li><a href="#emailDiv">修改邮箱</a></li>
        <li><a href="#avatarDiv">修改头像</a></li>
        <li><a href="#passwordDiv">修改密码</a></li>
      </ul>
    </div>
    <div class="right settings">
      <form class="form-horizontal" onsubmit="return;" id="baseDiv">
        <fieldset>
          <legend>基本信息</legend>
          <div>
            <p>用户名</p>
            <input type="text" id="username" name="username" disabled value="${user.username}"
                   placeholder="用户名">
          </div>
          <div>
            <p>Telegram用户名</p>
            <input type="text" id="telegramName" name="telegramName" value="${user.telegramName!}"
                   placeholder="Telegram用户名">
          </div>
          <div>
            <p>个人主页</p>
            <input type="text" id="website" name="website" value="${user.website!}"
                   placeholder="个人主页">
          </div>
          <div>
            <p>个人简介</p>
            <textarea name="bio" id="bio" rows="3"
                      placeholder="个人简介">${user.bio!?html}</textarea>
          </div>
          <div>
            <p>
              <input type="checkbox" id="emailNotification" style="vertical-align: middle;" <#if user.emailNotification>checked</#if>>
              <label for="emailNotification">有新消息发送邮件</label>
            </p>
          </div>
          <div>
            <button type="button" id="settings_btn" class="btn btn-info">提交</button>
          </div>
        </fieldset>
      </form>
      <br>
      <form onsubmit="return;" class="form-horizontal" id="emailDiv">
        <fieldset>
          <legend>修改邮箱</legend>
          <div>
            <p>邮箱</p>
            <input type="email" name="email" id="email" value="${user.email!}"
                   placeholder="邮箱"/>
            <button type="button" id="sendEmailCode" class="btn btn-info" autocomplete="off"
                    data-loading-text="发送中...">发送验证码</button>
          </div>
          <div>
            <p>验证码</p>
            <input type="text" name="code" id="code" placeholder="验证码"/>
          </div>
          <div>
            <button type="button" id="settings_email_btn" class="btn btn-info">更改邮箱</button>
          </div>
        </fieldset>
      </form>
      <br>
      <form onsubmit="return;" class="form-horizontal" id="avatarDiv">
        <fieldset>
          <legend>修改头像</legend>
          <div>
            <p>当前头像</p>
            <img src="${user.avatar!}" width="24" alt="avatar"/>&nbsp;&nbsp;
            <img src="${user.avatar!}" width="36" style="vertical-align: bottom" alt="avatar"/>&nbsp;&nbsp;
            <img src="${user.avatar!}" width="54" style="vertical-align: bottom" alt="avatar"/>&nbsp;&nbsp;
            <a href="javascript:;" id="selectAvatar">上传新头像</a>
            <input type="file" style="display: none;" name="file" id="file"/>
          </div>
        </fieldset>
      </form>
      <br>
      <form onsubmit="return;" class="form-horizontal" id="passwordDiv">
        <fieldset>
          <legend>修改密码</legend>
          <div>
            <p>旧密码</p>
            <input type="password" name="oldPassword" id="oldPassword" placeholder="旧密码"/>
          </div>
          <div>
            <p>新密码</p>
            <input type="password" name="newPassword" id="newPassword" placeholder="新密码"/>
          </div>
          <div>
            <button type="button" id="settings_pwd_btn" class="btn btn-info">更改密码</button>
          </div>
        </fieldset>
      </form>
      <div>
        <p>Token: <code id="userToken">${_user.token}</code></p>
        <div>
          <span id="qrcode"></span>&nbsp;&nbsp;
          <a href="javascript:;" id="refreshToken">刷新Token</a>
        </div>
      </div>
    </div>
  </div>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.qrcode/1.0/jquery.qrcode.min.js"></script>
  <script>
    $(function () {
      $("#settings_btn").click(function () {
        var telegramName = $("#telegramName").val();
        var website = $("#website").val();
        var bio = $("#bio").val();
        var emailNotification = $("#emailNotification").is(":checked");
        $.post("/api/settings/update", {
          telegramName: telegramName,
          website: website,
          bio: bio,
          emailNotification: emailNotification,
          token: '${_user.token}',
        }, function (data) {
          if (data.code === 200) {
            window.location.reload();
          } else {
            alert(data.description);
          }
        })
      });

      // 上传头像
      $("#selectAvatar").click(function () {
        $("#file").click();
      });
      $("#file").change(function () {
        var fd = new FormData();
        fd.append("file", document.getElementById("file").files[0]);
        fd.append("token", "${_user.token}");
        $.post({
          url: "/api/settings/uploadAvatar",
          data: fd,
          dataType: 'json',
          processData: false,
          contentType: false,
          success: function (data) {
            if (data.code === 200) {
              $.each($(".settings img"), function (i, v) {
                $(v).attr("src", data.detail + "?ver=" + new Date());
              })
            } else {
              alert(data.description);
            }
          }
        })
      });

      // 更改邮箱
      $("#sendEmailCode").on("click", function () {
        $(this).attr("disabled", true);
        var email = $("#email").val();
        $.get("/api/settings/sendEmailCode?token=${_user.token}&email=" + email, function (data) {
          if (data.code === 200) {
            alert("发送成功");
          } else {
            alert(data.description);
          }
          $("#sendEmailCode").attr("disabled", false);
        })
      })
      $("#settings_email_btn").click(function () {
        var email = $("#email").val();
        var code = $("#code").val();
        $.post("/api/settings/updateEmail", {
          email: email,
          code: code,
          token: '${_user.token}',
        }, function (data) {
          if (data.code === 200) {
            window.location.reload();
          } else {
            alert(data.description);
          }
        })
      })

      // 更改密码
      $("#settings_pwd_btn").click(function () {
        var oldPassword = $("#oldPassword").val();
        var newPassword = $("#newPassword").val();
        if (!oldPassword) {
          alert("请输入旧密码");
          return;
        }
        if (!newPassword) {
          alert("请输入新密码");
          return;
        }
        $.post("/api/settings/updatePassword", {
          oldPassword: oldPassword,
          newPassword: newPassword,
          token: '${_user.token}',
        }, function (data) {
          if (data.code === 200) {
            alert("修改密码成功");
          } else {
            alert(data.description);
          }
        })
      });
    });
    $("#qrcode").qrcode({
      width: 180,
      height: 180,
      text: '${_user.token}'
    });

    var token = '${_user.token}';
    $("#refreshToken").on("click", function() {
      $.get("/api/settings/refreshToken?token=" + token, function (data) {
        if (data.code === 200) {
          $("#qrcode").html("");
          $("#qrcode").qrcode({
            width: 180,
            height: 180,
            text: data.detail
          });
          $("#userToken").text(data.detail);
          token = data.detail;
        } else {
          alert("刷新token失败");
        }
      })
    });
  </script>
</@html>
