<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>${message("admin.orderShipping.list")} </title>
<meta name="author" content="SHOP++ Team" />
<meta name="copyright" content="SHOP++" />
<link href="${base}/resources/admin/css/common.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="${base}/resources/admin/js/jquery.js"></script>
<script type="text/javascript" src="${base}/resources/admin/js/common.js"></script>
<script type="text/javascript" src="${base}/resources/admin/js/list.js"></script>
<script type="text/javascript" src="${base}/resources/admin/js/country.js"></script>
<script type="text/javascript">
$().ready(function() {

	[@flash_message /]

});
</script>
</head>
<body>
	<div class="breadcrumb">
		${message("admin.orderShipping.list")} <span>(${message("admin.page.total", page.total)})</span>
	</div>
	<form id="listForm" action="list" method="get">
		<input type="hidden" id="countryName" name="countryName" value="${countryName}" />
		<div class="bar">
			<div class="buttonGroup">
				<a href="javascript:;" id="deleteButton" class="iconButton disabled">
					<span class="deleteIcon">&nbsp;</span>${message("admin.common.delete")}
				</a>
				<a href="javascript:;" id="refreshButton" class="iconButton">
					<span class="refreshIcon">&nbsp;</span>${message("admin.common.refresh")}
				</a>
				<div id="pageSizeMenu" class="dropdownMenu">
					<a href="javascript:;" class="button">
						${message("admin.page.pageSize")}<span class="arrow">&nbsp;</span>
					</a>
					<ul>
						<li[#if page.pageSize == 10] class="current"[/#if] val="10">10</li>
						<li[#if page.pageSize == 20] class="current"[/#if] val="20">20</li>
						<li[#if page.pageSize == 50] class="current"[/#if] val="50">50</li>
						<li[#if page.pageSize == 100] class="current"[/#if] val="100">100</li>
					</ul>
				</div>
				<div id="countryMenu" class="dropdownMenu">
					<a href="javascript:;" class="button">
						${message("common.country")}<span class="arrow">&nbsp;</span>
					</a>
					<ul>
						<li[#if country.name == null] class="current"[/#if] val="">${message("common.country.all")}</li>
						[@country_list]
							[#list countrys as country]
								<li[#if country.name == countryName] class="current"[/#if] val="${country.name}">${message("${country.nameLocal}")}</li>
							[/#list]
						[/@country_list]
					</ul>
				</div>
			</div>
			<div id="searchPropertyMenu" class="dropdownMenu">
				<div class="search">
					<span class="arrow">&nbsp;</span>
					<input type="text" id="searchValue" name="searchValue" value="${page.searchValue}" maxlength="200" />
					<button type="submit">&nbsp;</button>
				</div>
				<ul>
					<li[#if page.searchProperty == "sn"] class="current"[/#if] val="sn">${message("OrderShipping.sn")}</li>
					<li[#if page.searchProperty == "trackingNo"] class="current"[/#if] val="trackingNo">${message("OrderShipping.trackingNo")}</li>
					<li[#if page.searchProperty == "consignee"] class="current"[/#if] val="consignee">${message("OrderShipping.consignee")}</li>
					<li[#if page.searchProperty == "area"] class="current"[/#if] val="area">${message("OrderShipping.area")}</li>
					<li[#if page.searchProperty == "address"] class="current"[/#if] val="address">${message("OrderShipping.address")}</li>
					<li[#if page.searchProperty == "zipCode"] class="current"[/#if] val="zipCode">${message("OrderShipping.zipCode")}</li>
					<li[#if page.searchProperty == "phone"] class="current"[/#if] val="phone">${message("OrderShipping.phone")}</li>
				</ul>
			</div>
		</div>
		<table id="listTable" class="list">
			<tr>
				<th class="check">
					<input type="checkbox" id="selectAll" />
				</th>
				<th>
					<a href="javascript:;" class="sort" name="sn">${message("OrderShipping.sn")}</a>
				</th>
				<th>
					<a href="javascript:;" class="sort" name="shippingMethod">${message("OrderShipping.shippingMethod")}</a>
				</th>
				<th>
					<a href="javascript:;" class="sort" name="deliveryCorp">${message("OrderShipping.deliveryCorp")}</a>
				</th>
				<th>
					<a href="javascript:;" class="sort" name="trackingNo">${message("OrderShipping.trackingNo")}</a>
				</th>
				<th>
					<a href="javascript:;" class="sort" name="consignee">${message("OrderShipping.consignee")}</a>
				</th>
				<th>
					<span>${message("OrderShipping.isDelivery")}</span>
				</th>
				<th>
					<a href="javascript:;" class="sort" name="createdDate">${message("admin.common.createdDate")}</a>
				</th>
				<th>
					<span>${message("common.country")}</span>
				</th>
				<th>
					<span>${message("admin.common.action")}</span>
				</th>
			</tr>
			[#list page.content as orderShipping]
				<tr>
					<td>
						<input type="checkbox" name="ids" value="${orderShipping.id}" />
					</td>
					<td>
						${orderShipping.sn}
					</td>
					<td>
						${orderShipping.shippingMethod}
					</td>
					<td>
						${orderShipping.deliveryCorp}
					</td>
					<td>
						${orderShipping.trackingNo}
					</td>
					<td>
						${orderShipping.consignee}
					</td>
					<td>
						${message(orderShipping.isDelivery?string('admin.common.true', 'admin.common.false'))}
					</td>
					<td>
						<span title="${orderShipping.createdDate?string("yyyy-MM-dd HH:mm:ss")}">${orderShipping.createdDate}</span>
					</td>
					<td>
						${message("${orderShipping.country.nameLocal}")}
					</td>
					<td>
						<a href="view?id=${orderShipping.id}">[${message("admin.common.view")}]</a>
					</td>
				</tr>
			[/#list]
		</table>
		[@pagination pageNumber = page.pageNumber totalPages = page.totalPages]
			[#include "/admin/include/pagination.ftl"]
		[/@pagination]
	</form>
</body>
</html>