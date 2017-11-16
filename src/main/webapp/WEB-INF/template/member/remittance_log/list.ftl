<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>${message("member.remittanceLog.list")}[#if showPowered] [/#if]</title>
<meta name="author" content="SHOP++ Team" />
<meta name="copyright" content="SHOP++" />
<link href="${base}/resources/member/css/animate.css" rel="stylesheet" type="text/css" />
<link href="${base}/resources/member/css/common.css" rel="stylesheet" type="text/css" />
<link href="${base}/resources/member/css/member.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="${base}/resources/member/js/jquery.js"></script>
<script type="text/javascript" src="${base}/resources/member/js/common.js"></script>
<script type="text/javascript">
$().ready(function() {
	
	[#if flashMessage?has_content]
		$.alert("${flashMessage}");
	[/#if]
	
});
</script>
</head>
<body>
	[#assign current = "remittanceList" /]
	[#include "/shop/include/header.ftl" /]
	<div class="container member">
		<div class="row">
			[#include "/member/include/navigation.ftl" /]
			<div class="span10">
				<div class="list">
					<div class="title">${message("member.remittanceLog.list")} </div>
					<table id="listTable" class="list">
						<tr>
							<th>
								${message("member.remittanceLog.name")}
							</th>
							<th>
								${message("member.remittanceLog.amount")}
							</th>
							<th>
								${message("member.remittanceLog.number")}
							</th>
							<th>
								${message("member.remittanceLog.date")}
							</th>
							<th>
								${message("member.remittanceLog.memo")}
							</th>
							<th>
								<span>${message("admin.remittance.confirmStatus")}</span>
							</th>
							<th>
								${message("shop.common.createdDate")}
							</th>
						</tr>
						[#list page.content as remittanceLog]
							<tr[#if !memberMessage_has_next] class="last"[/#if]>
								<td>
									<span title="${remittanceLog.name}">${abbreviate(remittanceLog.name, 30)}</span>
								</td>
								<td>
									<span title="${remittanceLog.amount}">${remittanceLog.amount}</span>
								</td>
								<td>
									<span title="${remittanceLog.remittanceNumber}">${remittanceLog.remittanceNumber}</span>
								</td>
								<td>
									<span title="${remittanceLog.remittanceDate?string("yyyy-MM-dd HH:mm:ss")}">${remittanceLog.remittanceDate}</span>
								</td>
								<td>
									<span title="${remittanceLog.memo}">${abbreviate(remittanceLog.memo, 30)}</span>
								</td>
								<td>
									${message("admin.remittance.confirmStatus." + remittanceLog.confirmStatus)}
								</td>
								<td>
									<span title="${remittanceLog.createdDate?string("yyyy-MM-dd HH:mm:ss")}">${remittanceLog.createdDate}</span>
								</td>
							</tr>
						[/#list]
					</table>
					[#if !page.content?has_content]
						<p>${message("member.common.noResult")}</p>
					[/#if]
				</div>
				[@pagination pageNumber = page.pageNumber totalPages = page.totalPages pattern = "?pageNumber={pageNumber}"]
					[#include "/member/include/pagination.ftl"]
				[/@pagination]
			</div>
		</div>
	</div>
	[#include "/shop/include/footer.ftl" /]
</body>
</html>