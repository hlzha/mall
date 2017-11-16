<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>${message("member.deposit.log")}[#if showPowered] [/#if]</title>
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
	[#assign current = "fiBankbookJournal" /]
	[#include "/shop/include/header.ftl" /]
	<div class="container member">
		<div class="row">
			[#include "/member/include/navigation.ftl" /]
			<div class="span10">
				<div class="list">
					<div class="title">${message("member.deposit.coupon")}</div>
					<table class="list">
						<tr>
							<th>
								${message("DepositLog.type")}
							</th>
							<th>
								${message("DepositLog.credit")}
							</th>
							<th>
								${message("DepositLog.debit")}
							</th>
							<th>
								${message("DepositLog.balance")}
							</th>
							<th>
								${message("DepositLog.memo")}
							</th>
							<th>
								${message("shop.common.createdDate")}
							</th>
						</tr>
						[#list page.content as fiBankbookJournal]
							<tr[#if !fiBankbookJournal_has_next] class="last"[/#if]>
								<td>
									${message("DepositLog.Type." + fiBankbookJournal.type)}
								</td>
								<td>
									[#if fiBankbookJournal.dealType == 'deposit']
										${currency(fiBankbookJournal.money,true)}
									[#else]
										-
									[/#if]
								</td>
								<td>
									[#if fiBankbookJournal.dealType == 'takeout']
										${currency(fiBankbookJournal.money,true)}
									[#else]
										-
									[/#if]
								</td>
								<td>
									${currency(fiBankbookJournal.balance,true)}
								</td>
								<td>
									${fiBankbookJournal.notes}
								</td>
								<td>
									<span title="${fiBankbookJournal.createdDate?string("yyyy-MM-dd HH:mm:ss")}">${fiBankbookJournal.createdDate}</span>
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