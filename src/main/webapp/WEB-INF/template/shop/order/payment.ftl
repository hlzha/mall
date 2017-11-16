<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>${message("shop.order.payment")}[#if showPowered] [/#if]</title>
<meta name="author" content="SHOP++ Team" />
<meta name="copyright" content="SHOP++" />
    <link href="${base}/favicon.ico" rel="shortcut icon" type="image/x-icon"/>
<link href="${base}/resources/shop/css/animate.css" rel="stylesheet" type="text/css" />
<link href="${base}/resources/shop/css/common.css" rel="stylesheet" type="text/css" />
<link href="${base}/resources/shop/css/order.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="${base}/resources/shop/js/jquery.js"></script>
<script type="text/javascript" src="${base}/resources/shop/js/common.js"></script>
<script type="text/javascript">
$().ready(function() {

	var $dialogOverlay = $("#dialogOverlay");
	var $dialog = $("#dialog");
	var $other = $("#other");
	var $amountPayable = $("#amountPayable");
	var $fee = $("#fee");
	var $paymentForm = $("#paymentForm");
	var $paymentPluginId = $("#paymentPlugin input:radio");
	var $paymentButton = $("#paymentButton");
	
	[#if order.paymentMethod.method == "online"]
		// 获取订单锁
		function acquireLock() {
			$.ajax({
				url: "acquire_lock",
				type: "POST",
				data: {sn: ${order.sn}},
				dataType: "json"
			});
		}
		
		// 获取订单锁
		acquireLock();
		setInterval(function() {
			acquireLock();
		}, 50000);
		
		// 检查等待付款
		setInterval(function() {
			$.ajax({
				url: "check_pending_payment",
				type: "GET",
				data: {sn: "${order.sn}"},
				dataType: "json",
				success: function(data) {
					if (!data) {
						location.href = "${base}/member/order/view?orderSn=${order.sn}";
					}
				}
			});
		}, 10000);
	[/#if]
	
	// 选择其它支付方式
	$other.click(function() {
		$dialogOverlay.hide();
		$dialog.hide();
	});
	
	// 支付插件
	$paymentPluginId.click(function() {
		$.ajax({
			url: "calculate_amount",
			type: "GET",
			data: {paymentPluginId: $(this).val(), sn: "${order.sn}"},
			dataType: "json",
			success: function(data) {
				$amountPayable.text(currency(data.amount, true, true));
				if (data.fee > 0) {
					$fee.text(currency(data.fee, true)).parent().show();
				} else {
					$fee.parent().hide();
				}
			}
		});
	});
	
	// 支付
	$paymentForm.submit(function() {
		$dialogOverlay.show();
		$dialog.show();
	});

});
</script>
</head>
<body>
	<div id="dialogOverlay" class="dialogOverlay"></div>
	[#include "/shop/include/header.ftl" /]
	<div class="container payment">
		<div class="row">
			<div class="span12">
				<div id="dialog" class="dialog">
					[#noautoesc]
						${message("shop.order.paymentDialog")}
					[/#noautoesc]
					<div>
						<a href="${base}/member/order/view?orderSn=${order.sn}">${message("shop.order.paid")}</a>
						<a href="${base}/">${message("shop.order.trouble")}</a>
					</div>
					<a href="javascript:;" id="other">${message("shop.order.otherPaymentMethod")}</a>
				</div>
				<div class="result">
					[#if order.status == "pendingPayment"]
						<div class="title">${message("shop.order.pendingPayment")}</div>
					[#elseif order.status == "pendingReview"]
						<div class="title">${message("shop.order.pendingReview")}</div>
					[#else]
						<div class="title">${message("shop.order.pending")}</div>
					[/#if]
					<table>
						<tr>
							<th colspan="4">${message("shop.order.info")}:</th>
						</tr>
						<tr>
							<td width="100">${message("Order.sn")}:</td>
							<td width="340">
								<strong>${order.sn}</strong>
								<a href="${base}/member/order/view?orderSn=${order.sn}">[${message("shop.order.view")}]</a>
							</td>
							<td width="100">${message("Order.amountPayable")}:</td>
							<td>
								[#if amount??]
									<strong id="amountPayable">${currency(amount, true, true)}</strong>
								[#else]
									<strong id="amountPayable">${currency(order.amountPayable, true, true)}</strong>
								[/#if]
								[#if fee??]
									<span[#if fee <= 0] class="hidden"[/#if]>(${message("Order.fee")}: <span id="fee">${currency(fee, true)}</span>)</span>
								[#else]
									<span[#if order.fee <= 0] class="hidden"[/#if]>(${message("Order.fee")}: <span id="fee">${currency(order.fee, true)}</span>)</span>
								[/#if]
							</td>
						</tr>
						<tr>
							<td width="100">${message("Order.amountPayable")}:</td>
							<td>
								[#if couponPrice??]
									<strong id="couponPrice">${currency(couponPrice, true, true)}</strong>
								[#else]
									<strong id="couponPrice">${currency(order.couponPrice, true)}</strong>
								[/#if]
							</td>
							<td>${message("Order.shippingMethod")}:</td>
							<td>${order.shippingMethodName!"-"}</td>
						</tr>
						<tr>
							<td>${message("Order.paymentMethod")}:</td>
							<td>${order.paymentMethodName!"-"}</td>
							[#if order.expire??]
								<td colspan="4">${message("shop.order.expireTips", order.expire?string("yyyy-MM-dd HH:mm"))}</td>
							[/#if]
						</tr>
					</table>
					[#if order.paymentMethod.method == "online"]
						[#if paymentPlugins?has_content]
							<form id="paymentForm" action="${base}/payment" method="post" target="_blank">
								<input type="hidden" name="type" value="ORDER_PAYMENT" />
								<input type="hidden" name="orderSn" value="${order.sn}" />
								<table id="paymentPlugin" class="paymentPlugin">
									<tr>
										<th colspan="4">${message("Order.paymentMethod")}:</th>
									</tr>
									[#list paymentPlugins?chunk(4, "") as row]
										<tr>
											[#list row as paymentPlugin]
												[#if paymentPlugin?has_content]
													<td>
														<input type="radio" id="${paymentPlugin.id}" name="paymentPluginId" value="${paymentPlugin.id}"[#if paymentPlugin == defaultPaymentPlugin] checked="checked"[/#if] />
														<label for="${paymentPlugin.id}">
															[#if paymentPlugin.logo?has_content]
																<em title="${paymentPlugin.paymentName}" style="background-image: url(${paymentPlugin.logo});">&nbsp;</em>
															[#else]
																<em>${paymentPlugin.paymentName}</em>
															[/#if]
														</label>
													</td>
												[#else]
													<td>
														&nbsp;
													</td>
												[/#if]
											[/#list]
										</tr>
									[/#list]
								</table>
								<input type="submit" id="paymentButton" class="paymentButton" value="${message("shop.order.payNow")}" />
							</form>
						[/#if]
					[#else]
						[#noautoesc]
							${order.paymentMethod.content}
						[/#noautoesc]
					[/#if]
				</div>
			</div>
		</div>
	</div>
	[#include "/shop/include/footer.ftl" /]
</body>
</html>