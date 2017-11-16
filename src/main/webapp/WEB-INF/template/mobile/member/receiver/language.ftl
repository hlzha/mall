<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
	<meta name="format-detection" content="telephone=no">
	<meta name="author" content="SHOP++ Team">
	<meta name="copyright" content="SHOP++">
	<title>${message("member.navigation.languageSetting")}[#if showPowered] [/#if]</title>
	<link href="${base}/favicon.ico" rel="icon">
	<link href="${base}/resources/mobile/member/css/bootstrap.css" rel="stylesheet">
	<link href="${base}/resources/mobile/member/css/font-awesome.css" rel="stylesheet">
	<link href="${base}/resources/mobile/member/css/animate.css" rel="stylesheet">
	<link href="${base}/resources/mobile/member/css/common.css" rel="stylesheet">
	<link href="${base}/resources/mobile/member/css/profile.css" rel="stylesheet">
	<!--[if lt IE 9]>
		<script src="${base}/resources/mobile/member/js/html5shiv.js"></script>
		<script src="${base}/resources/mobile/member/js/respond.js"></script>
	<![endif]-->
	<script src="${base}/resources/mobile/member/js/jquery.js"></script>
	<script src="${base}/resources/mobile/member/js/bootstrap.js"></script>
	<script src="${base}/resources/mobile/member/js/velocity.js"></script>
	<script src="${base}/resources/mobile/member/js/velocity.ui.js"></script>
	<script src="${base}/resources/mobile/member/js/underscore.js"></script>
	<script src="${base}/resources/mobile/member/js/common.js"></script>
	<script type="text/javascript">
		$().ready(function() {

            var $change = $(".change button");
            $change.click(function () {
                var language = $(this).val();
                changeLanguage(language);
                $(this).addClass('btn-primary').siblings().removeClass('btn-primary');

            });

            function changeLanguage(language){

                $.ajax({
                    url: "${base}/common/language/change",
                    type: "POST",
                    data: {code: language},
                    dataType: "json",
                    cache: false,
                    success: function(message) {
                        window.location.reload();
                    }
                });
            }
		
		});
	</script>
    <style>
		.active{
			color: #ef0101 !important;
		}
		.language{
			text-align: center;
			color: #9d9d9d;
		}
		.list-group-flat{
			padding: 13px 10px;
		}
	</style>
</head>
<body class="profile">
	<header class="header-fixed">
		<a class="pull-left" href="${base}/member/index">
			<span class="glyphicon glyphicon-menu-left"></span>
		</a>
		${message("member.navigation.languageSetting")}
	</header>
	<main>
		<div class="change container-fluid" style="padding-top: 10px">
		[@language]
			[#list languages as language]
                <button class="btn btn-default btn-block" value="${language.code}">${message("${language.message}")}</button>
			[/#list]
		[/@language]
		</div>
	</main>

</body>
</html>