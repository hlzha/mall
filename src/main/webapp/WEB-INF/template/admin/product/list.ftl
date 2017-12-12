<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>${message("admin.product.list")} </title>
<meta name="author" content="SHOP++ Team" />
<meta name="copyright" content="SHOP++" />
<link href="${base}/resources/admin/css/common.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="${base}/resources/admin/js/jquery.js"></script>
<script type="text/javascript" src="${base}/resources/admin/js/common.js"></script>
<script type="text/javascript" src="${base}/resources/admin/js/list.js"></script>
<style type="text/css">
.moreTable th {
	width: 80px;
	line-height: 25px;
	padding: 5px 10px 5px 0px;
	text-align: right;
	font-weight: normal;
	color: #333333;
	background-color: #f8fbff;
}

.moreTable td {
	line-height: 25px;
	padding: 5px;
	color: #666666;
}

.promotion {
	color: #cccccc;
}

.stockAlert {
	color: orange;
}

.outOfStock {
	color: red;
	font-weight: bold;
}
</style>
<script type="text/javascript">
$().ready(function() {

	var $listForm = $("#listForm");
	var $filterMenu = $("#filterMenu");
	var $filterMenuItem = $("#filterMenu li");
	var $moreButton = $("#moreButton");
	var $countryId = $("#countryId");
	var $typeMenu = $("#typeMenu");
	var $typeMenuItem = $("#typeMenu li");
	
	[@flash_message /]
	
	
	$typeMenu.hover(
		function() {
			$(this).children("ul").show();
		}, function() {
			$(this).children("ul").hide();
		}
	);
	
	$typeMenuItem.click(function() {
		$countryId.val($(this).attr("val"));
		$listForm.submit();
	});
	
	// 筛选菜单
	$filterMenu.hover(
		function() {
			$(this).children("ul").show();
		}, function() {
			$(this).children("ul").hide();
		}
	);
	
	// 筛选
	$filterMenuItem.click(function() {
		var $this = $(this);
		var $dest = $("#" + $this.attr("name"));
		if ($this.hasClass("checked")) {
			$dest.val("");
		} else {
			$dest.val($this.attr("val"));
		}
		$listForm.submit();
	});
	
	// 更多选项
	$moreButton.click(function() {
		$.dialog({
			title: "${message("admin.product.moreOption")}",
			[@compress single_line = true]
				content: '
				<table id="moreTable" class="moreTable">
					<tr>
						<th>
							${message("Product.productCategory")}:
						<\/th>
						<td>
							<select name="productCategoryId">
								<option value="">${message("admin.common.choose")}<\/option>
								[#list productCategoryTree as productCategory]
									<option value="${productCategory.id}"[#if productCategory.id == productCategoryId] selected="selected"[/#if]>
										[#if productCategory.grade != 0]
											[#list 1..productCategory.grade as i]
												&nbsp;&nbsp;
											[/#list]
										[/#if]
										[#noautoesc]
											${productCategory.name?html?js_string}
										[/#noautoesc]
									<\/option>
								[/#list]
							<\/select>
						<\/td>
					<\/tr>
					<tr>
						<th>
							${message("Product.type")}:
						<\/th>
						<td>
							<select name="type">
								<option value="">${message("admin.common.choose")}<\/option>
								[#list types as value]
									<option value="${value}"[#if value == type] selected="selected"[/#if]>${message("Product.Type." + value)}<\/option>
								[/#list]
							<\/select>
						<\/td>
					<\/tr>
					<tr>
						<th>
							${message("Product.brand")}:
						<\/th>
						<td>
							<select name="brandId">
								<option value="">${message("admin.common.choose")}<\/option>
								[#list brands as brand]
									<option value="${brand.id}"[#if brand.id == brandId] selected="selected"[/#if]>
										[#noautoesc]
											${brand.name?html?js_string}
										[/#noautoesc]
									<\/option>
								[/#list]
							<\/select>
						<\/td>
					<\/tr>
					<tr class="hidden">
						<th>
							${message("Product.productTags")}:
						<\/th>
						<td>
							<select name="productTagId">
								<option value="">${message("admin.common.choose")}<\/option>
								[#list productTags as productTag]
									<option value="${productTag.id}"[#if productTag.id == productTagId] selected="selected"[/#if]>
										[#noautoesc]
											${productTag.name?html?js_string}
										[/#noautoesc]
									<\/option>
								[/#list]
							<\/select>
						<\/td>
					<\/tr>
					<tr class="hidden">
						<th>
							${message("Product.promotions")}:
						<\/th>
						<td>
							<select name="promotionId">
								<option value="">${message("admin.common.choose")}<\/option>
								[#list promotions as promotion]
									<option value="${promotion.id}"[#if promotion.id == promotionId] selected="selected"[/#if]>
										[#noautoesc]
											${promotion.name?html?js_string}
										[/#noautoesc]
									<\/option>
								[/#list]
							<\/select>
						<\/td>
					<\/tr>
				<\/table>',
			[/@compress]
			width: 470,
			modal: true,
			ok: "${message("admin.dialog.ok")}",
			cancel: "${message("admin.dialog.cancel")}",
			onOk: function() {
				$("#moreTable :input").each(function() {
					var $this = $(this);
					$("#" + $this.attr("name")).val($this.val());
				});
				$listForm.submit();
			}
		});
	});
	$("#exportExcel").click(function(){  
        var url = "exprotProductList";  
        $('#listForm').attr('action', url);  
        $('#listForm').submit();  
        $('#listForm').attr('action', "list");  
         
    });  

});
</script>
</head>
<body>
	<div class="breadcrumb">
		${message("admin.product.list")} <span>(${message("admin.page.total", page.total)})</span>
	</div>
	<form id="listForm" action="list" method="get">
		<input type="hidden" id="countryId" name="countryId" value="${countryId}" />
		<input type="hidden" id="type" name="type" value="${type}" />
		<input type="hidden" id="productCategoryId" name="productCategoryId" value="${productCategoryId}" />
		<input type="hidden" id="brandId" name="brandId" value="${brandId}" />
		<input type="hidden" id="productTagId" name="productTagId" value="${productTagId}" />
		<input type="hidden" id="promotionId" name="promotionId" value="${promotionId}" />
		<input type="hidden" id="isMarketable" name="isMarketable" value="${(isMarketable?string("true", "false"))!}" />
		<input type="hidden" id="isList" name="isList" value="${(isList?string("true", "false"))!}" />
		<input type="hidden" id="isTop" name="isTop" value="${(isTop?string("true", "false"))!}" />
		<input type="hidden" id="isOutOfStock" name="isOutOfStock" value="${(isOutOfStock?string("true", "false"))!}" />
		<input type="hidden" id="isStockAlert" name="isStockAlert" value="${(isStockAlert?string("true", "false"))!}" />
		<div class="bar">
			<a href="add" class="iconButton">
				<span class="addIcon">&nbsp;</span>${message("admin.common.add")}
			</a>
			<a href="download" class="iconButton">
				<span class="addIcon">&nbsp;</span>下载
			</a>
			<a href="javascript:;" id="exportExcel" class="iconButton">
				<span class="addIcon">&nbsp;</span>下载
			</a>
			<div class="buttonGroup">
				<a href="javascript:;" id="deleteButton" class="iconButton disabled">
					<span class="deleteIcon">&nbsp;</span>${message("admin.common.delete")}
				</a>
				<a href="javascript:;" id="refreshButton" class="iconButton">
					<span class="refreshIcon">&nbsp;</span>${message("admin.common.refresh")}
				</a>
				<div id="typeMenu" class="dropdownMenu">
					<a href="javascript:;" class="button">
						${message("Brand.country")}<span class="arrow">&nbsp;</span>
					</a>
					<ul>
						<li[#if countryId == null] class="current"[/#if] val="">${message("Brand.country.all")}</li>
						[#assign currentType = countryId]
						[#list countries as country]
							<li[#if country.id == currentType] class="current"[/#if] val="${country.id}">${country.name}</li>
						[/#list]
					</ul>
			 	</div>
				<div id="filterMenu" class="dropdownMenu">
					<a href="javascript:;" class="button">
						${message("admin.product.filter")}<span class="arrow">&nbsp;</span>
					</a>
					<ul class="check">
						<li name="isMarketable"[#if isMarketable?? && isMarketable] class="checked"[/#if] val="true">${message("admin.product.isMarketable")}</li>
						<li name="isMarketable"[#if isMarketable?? && !isMarketable] class="checked"[/#if] val="false">${message("admin.product.notMarketable")}</li>
						<li class="divider">&nbsp;</li>
						<li name="isList"[#if isList?? && isList] class="checked"[/#if] val="true">${message("admin.product.isList")}</li>
						<li name="isList"[#if isList?? && !isList] class="checked"[/#if] val="false">${message("admin.product.notList")}</li>
						<li class="divider">&nbsp;</li>
						<li name="isTop"[#if isTop?? && isTop] class="checked"[/#if] val="true">${message("admin.product.isTop")}</li>
						<li name="isTop"[#if isTop?? && !isTop] class="checked"[/#if] val="false">${message("admin.product.notTop")}</li>
						<li class="divider">&nbsp;</li>
						<li name="isOutOfStock"[#if isOutOfStock?? && !isOutOfStock] class="checked"[/#if] val="false">${message("admin.product.isStack")}</li>
						<li name="isOutOfStock"[#if isOutOfStock?? && isOutOfStock] class="checked"[/#if] val="true">${message("admin.product.isOutOfStack")}</li>
						<li class="divider">&nbsp;</li>
						<li name="isStockAlert"[#if isStockAlert?? && !isStockAlert] class="checked"[/#if] val="false">${message("admin.product.normalStore")}</li>
						<li name="isStockAlert"[#if isStockAlert?? && isStockAlert] class="checked"[/#if] val="true">${message("admin.product.isStockAlert")}</li>
					</ul>
				</div>
				<a href="javascript:;" id="moreButton" class="button">${message("admin.product.moreOption")}</a>
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
			</div>
			<div id="searchPropertyMenu" class="dropdownMenu">
				<div class="search">
					<span class="arrow">&nbsp;</span>
					<input type="text" id="searchValue" name="searchValue" value="${page.searchValue}" maxlength="200" />
					<button type="submit">&nbsp;</button>
				</div>
				<ul>
					<li[#if page.searchProperty == "sn"] class="current"[/#if] val="sn">${message("Product.sn")}</li>
					<li[#if page.searchProperty == "name"] class="current"[/#if] val="name">${message("Product.name")}</li>
				</ul>
			</div>
		</div>
		<table id="listTable" class="list">
			<tr>
				<th class="check">
					<input type="checkbox" id="selectAll" />
				</th>
				<th>
					<a href="javascript:;" class="sort" name="name">${message("Brand.country")}</a>
				</th>
				<th>
					<a href="javascript:;" class="sort" name="sn">${message("Product.sn")}</a>
				</th>
				<th>
					<a href="javascript:;" class="sort" name="name">${message("Product.name")}</a>
				</th>
				<th>
					<a href="javascript:;" class="sort" name="productCategory">${message("Product.productCategory")}</a>
				</th>
				<!-- th>
					<span>${message("Product.price")}</span>
				</th>
				<th>
					<span>${message("Product.coupon")}</span>
				</th>-->
				<th>
					<a href="javascript:;" class="sort" name="isMarketable">${message("Product.isMarketable")}</a>
				</th>
				<th>
					<a href="javascript:;" class="sort" name="isMarketable">${message("Product.isTop")}</a>
				</th>
				<th>
					<a href="javascript:;" class="sort" name="createdDate">${message("admin.common.createdDate")}</a>
				</th>
				<th>
					<span>${message("admin.common.action")}</span>
				</th>
			</tr>
			[#list page.content as product]
				<tr>
					<td>
						<input type="checkbox" name="ids" value="${product.id}" />
					</td>
					<td>
						${product.productCategory.country.name}
					</td>
					<td>
						<span[#if product.isOutOfStock] class="red"[#elseif product.isStockAlert] class="blue"[/#if]>
							${product.sn}
						</span>
					</td>
					<td>
						<span title="${product.name}">
							${abbreviate(product.name, 50, "...")}
						</span>
						[#if product.type != "general"]
							<span class="red">*</span>
						[/#if]
						[#list product.validPromotions as promotion]
							<span class="promotion" title="${promotion.title}">${promotion.name}</span>
						[/#list]
					</td>
					<td>
						${product.productCategory.name}
					</td>
					<!--td>
						${currency(product.price, true)}
					</td>
					<td>
						${product.coupon}
					</td -->
					<td>
						<span class="${product.isMarketable?string("true", "false")}Icon">&nbsp;</span>
					</td>
					<td>
						<span class="${product.isTop?string("true", "false")}Icon">&nbsp;</span>
					</td>
					<td>
						<span title="${product.createdDate?string("yyyy-MM-dd HH:mm:ss")}">${product.createdDate}</span>
					</td>
					<td>
						<a href="edit?id=${product.id}">[${message("admin.common.edit")}]</a>
						[#if product.isMarketable]
							<a href="${base}${product.path}" target="_blank">[${message("admin.common.view")}]</a>
						[#else]
							<span title="${message("admin.product.notMarketable")}">[${message("admin.common.view")}]</span>
						[/#if]
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