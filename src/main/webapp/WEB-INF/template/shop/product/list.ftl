<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
[#if productCategory??]
	[@seo type = "productList"]
		<title>[#if productCategory.resolveSeoTitle()?has_content]${productCategory.resolveSeoTitle()}[#else]${seo.resolveTitle()}[/#if][#if showPowered] [/#if]</title>
		<meta name="author" content="SHOP++ Team" />
		<meta name="copyright" content="SHOP++" />
		[#if productCategory.resolveSeoKeywords()?has_content]
			<meta name="keywords" content="${productCategory.resolveSeoKeywords()}" />
		[#elseif seo.resolveKeywords()?has_content]
			<meta name="keywords" content="${seo.resolveKeywords()}" />
		[/#if]
		[#if productCategory.resolveSeoDescription()?has_content]
			<meta name="description" content="${productCategory.resolveSeoDescription()}" />
		[#elseif seo.resolveDescription()?has_content]
			<meta name="description" content="${seo.resolveDescription()}" />
		[/#if]
	[/@seo]
[#else]
	<title>${message("shop.product.title")}[#if showPowered] [/#if]</title>
	<meta name="author" content="SHOP++ Team" />
	<meta name="copyright" content="SHOP++" />
[/#if]
    <link href="${base}/favicon.ico" rel="shortcut icon" type="image/x-icon"/>
<link href="${base}/resources/shop/css/animate.css" rel="stylesheet" type="text/css" />
<link href="${base}/resources/shop/css/common.css" rel="stylesheet" type="text/css" />
<link href="${base}/resources/shop/css/product.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="${base}/resources/shop/js/jquery.js"></script>
<script type="text/javascript" src="${base}/resources/shop/js/jquery.lazyload.js"></script>
<script type="text/javascript" src="${base}/resources/shop/js/common.js"></script>
<script type="text/javascript">
$().ready(function() {

	var $headerCart = $("#headerCart");
	var $compareBar = $("#compareBar");
	var $compareForm = $("#compareBar form");
	var $compareSubmit = $("#compareBar a.submit");
	var $clearCompare = $("#compareBar a.clear");
	var $productForm = $("#productForm");
	var $brandId = $("#brandId");
	var $promotionId = $("#promotionId");
	var $orderType = $("#orderType");
	var $pageNumber = $("#pageNumber");
	var $pageSize = $("#pageSize");
	var $filter = $("#filter dl");
	var $hiddenFilter = $("#filter dl:hidden");
	var $moreOption = $("#filter dd.moreOption");
	var $brand = $("#filter a.brand");
	var $attribute = $("#filter a.attribute");
	var $moreFilter = $("#moreFilter a");
	var $gridType = $("#gridType");
	var $listType = $("#listType");
	var $size = $("#layout a.size");
	var $previousPage = $("#previousPage");
	var $nextPage = $("#nextPage");
	var $sort = $("#sort a, #sort li");
	var $orderMenu = $("#orderMenu");
	var $startPrice = $("#startPrice");
	var $endPrice = $("#endPrice");
	var $result = $("#result");
	var $productImage = $("#result img");
	var $addCart = $("#result a.addCart");
	var $exchange = $("#result a.exchange");
	var $addProductFavorite = $("#result a.addProductFavorite");
	var $addCompare = $("#result a.addCompare");
	
	[#if productCategory??]
		$filter.each(function() {
			var $this = $(this);
			var scrollHeight = this.scrollHeight > 0 ? this.scrollHeight : $.swap(this, {display: "block", position: "absolute", visibility: "hidden"}, function() {
				return this.scrollHeight;
			});
			if (scrollHeight > 30) {
				if ($this.find("a.current").size() > 0) {
					$this.height("auto");
				} else {
					$this.find("dd.moreOption").show();
				}
			}
		});
		
		$moreOption.click(function() {
			var $this = $(this);
			if ($this.hasClass("close")) {
				$this.removeClass("close");
				$this.attr("title", "${message("shop.product.moreOption")}");
				$this.parent().height(30);
			} else {
				$this.addClass("close");
				$this.attr("title", "${message("shop.product.closeOption")}");
				$this.parent().height("auto");
			}
		});
		
		$moreFilter.click(function() {
			var $this = $(this);
			if ($this.hasClass("close")) {
				$this.removeClass("close");
				$this.text("${message("shop.product.moreFilter")}");
				$hiddenFilter.hide();
			} else {
				$this.addClass("close");
				$this.text("${message("shop.product.closeFilter")}");
				$hiddenFilter.show();
			}
			return false;
		});
		
		$brand.click(function() {
			var $this = $(this);
			if ($this.hasClass("current")) {
				$brandId.val("");
			} else {
				$brandId.val($this.attr("brandId"));
			}
			$pageNumber.val(1);
			$productForm.submit();
			return false;
		});
		
		$attribute.click(function() {
			var $this = $(this);
			if ($this.hasClass("current")) {
				$this.closest("dl").find("input").prop("disabled", true);
			} else {
				$this.closest("dl").find("input").prop("disabled", false).val($this.text());
			}
			$pageNumber.val(1);
			$productForm.submit();
			return false;
		});
	[/#if]
	
	var layoutType = getCookie("layoutType");
	if (layoutType == "listType") {
		$listType.addClass("currentList");
		$result.removeClass("grid").addClass("list");
	} else {
		$gridType.addClass("currentGrid");
		$result.removeClass("list").addClass("grid");
	}
	
	$gridType.click(function() {
		var $this = $(this);
		if (!$this.hasClass("currentGrid")) {
			$this.addClass("currentGrid");
			$listType.removeClass("currentList");
			$result.removeClass("list").addClass("grid");
			addCookie("layoutType", "gridType");
		}
		return false;
	});
	
	$listType.click(function() {
		var $this = $(this);
		if (!$this.hasClass("currentList")) {
			$this.addClass("currentList");
			$gridType.removeClass("currentGrid");
			$result.removeClass("grid").addClass("list");
			addCookie("layoutType", "listType");
		}
		return false;
	});
	
	$size.click(function() {
		var $this = $(this);
		$pageNumber.val(1);
		$pageSize.val($this.attr("pageSize"));
		$productForm.submit();
		return false;
	});
	
	$previousPage.click(function() {
		$pageNumber.val(${page.pageNumber - 1});
		$productForm.submit();
		return false;
	});
	
	$nextPage.click(function() {
		$pageNumber.val(${page.pageNumber + 1});
		$productForm.submit();
		return false;
	});
	
	$orderMenu.hover(
		function() {
			$(this).children("ul").show();
		}, function() {
			$(this).children("ul").hide();
		}
	);
	
	$sort.click(function() {
		var $this = $(this);
		if ($this.hasClass("current")) {
			$orderType.val("");
		} else {
			$orderType.val($this.attr("orderType"));
		}
		$pageNumber.val(1);
		$productForm.submit();
		return false;
	});
	
	$startPrice.add($endPrice).focus(function() {
		$(this).siblings("button").show();
	});
	
	$startPrice.add($endPrice).keypress(function(event) {
		return (event.which >= 48 && event.which <= 57) || (event.which == 46 && $(this).val().indexOf(".") < 0) || event.which == 8 || event.which == 13;
	});
	
	$productForm.submit(function() {
		if ($brandId.val() == "") {
			$brandId.prop("disabled", true);
		}
		if ($promotionId.val() == "") {
			$promotionId.prop("disabled", true);
		}
		if ($orderType.val() == "" || $orderType.val() == "topDesc") {
			$orderType.prop("disabled", true);
		}
		if ($pageNumber.val() == "" || $pageNumber.val() == "1") {
			$pageNumber.prop("disabled", true);
		}
		if ($pageSize.val() == "" || $pageSize.val() == "20") {
			$pageSize.prop("disabled", true);
		}
		if ($startPrice.val() == "" || !/^\d+(\.\d+)?$/.test($startPrice.val())) {
			$startPrice.prop("disabled", true);
		}
		if ($endPrice.val() == "" || !/^\d+(\.\d+)?$/.test($endPrice.val())) {
			$endPrice.prop("disabled", true);
		}
		if ($productForm.serializeArray().length < 1) {
			location.href = location.pathname;
			return false;
		}
	});
	
	$productImage.lazyload({
		threshold: 100,
		effect: "fadeIn"
	});
	
	// 加入购物车
	$addCart.click(function() {
		var $this = $(this);
		var skuId = $this.attr("skuId");
		$.ajax({
			url: "${base}/cart/add",
			type: "POST",
			data: {skuId: skuId, quantity: 1},
			dataType: "json",
			success: function() {
				if ($headerCart.size() > 0 && window.XMLHttpRequest) {
					var $image = $this.closest("li").find("img");
					var cartOffset = $headerCart.offset();
					var imageOffset = $image.offset();
					$image.clone().css({
						width: 170,
						height: 170,
						position: "absolute",
						"z-index": 20,
						top: imageOffset.top,
						left: imageOffset.left,
						opacity: 0.8,
						border: "1px solid #dddddd",
						"background-color": "#eeeeee"
					}).appendTo("body").animate({
						width: 30,
						height: 30,
						top: cartOffset.top,
						left: cartOffset.left,
						opacity: 0.2
					}, 1000, function() {
						$(this).remove();
					});
				}
			}
		});
		return false;
	});
	
	// 积分兑换
	$exchange.click(function() {
		var skuId = $(this).attr("skuId");
		$.ajax({
			url: "${base}/order/check_exchange",
			type: "GET",
			data: {skuId: skuId, quantity: 1},
			dataType: "json",
			success: function() {
				location.href = "${base}/order/checkout?type=exchange&skuId=" + skuId + "&quantity=1";
			}
		});
		return false;
	});
	
	// 添加商品收藏
	$addProductFavorite.click(function() {
		var productId = $(this).attr("productId");
		$.ajax({
			url: "${base}/member/product_favorite/add",
			type: "POST",
			data: {productId: productId},
			dataType: "json"
		});
		return false;
	});
	
	// 对比栏
	var compareProduct = getCookie("compareProduct");
	var compareProductIds = compareProduct != null ? compareProduct.split(",") : [];
	if (compareProductIds.length > 0) {
		$.ajax({
			url: "${base}/product/compare_bar",
			type: "GET",
			data: {productIds: compareProductIds},
			dataType: "json",
			success: function(data) {
				$.each(data, function (i, item) {
					var thumbnail = item.thumbnail != null ? item.thumbnail : "${setting.defaultThumbnailProductImage}";
					$compareBar.find("dt").after(
						[@compress single_line = true]
							'<dd>
								<input type="hidden" name="productIds" value="' + item.id + '" \/>
								<a href="${base}' + escapeHtml(item.path) + '" target="_blank">
									<img src="' + escapeHtml(thumbnail) + '" \/>
									<span title="' + escapeHtml(item.name) + '">' + escapeHtml(abbreviate(item.name, 50)) + '<\/span>
								<\/a>
								<strong>' + currency(item.price, true) + '[#if setting.isShowMarketPrice]<del>' + currency(item.marketPrice, true) + '<\/del>[/#if]<\/strong>
								<a href="javascript:;" class="remove" productId="' + item.id + '">[${message("shop.common.remove")}]<\/a>
							<\/dd>'
						[/@compress]
					);
				});
				$compareBar.fadeIn();
			}
		});
		
		$.each(compareProductIds, function(i, productId) {
			$addCompare.filter("[productId='" + productId + "']").addClass("selected");
		});
	}
	
	// 移除对比
	$compareBar.on("click", "a.remove", function() {
		var $this = $(this);
		var productId = $this.attr("productId");
		$this.closest("dd").remove();
		for (var i = 0; i < compareProductIds.length; i ++) {
			if (compareProductIds[i] == productId) {
				compareProductIds.splice(i, 1);
				break;
			}
		}
		$addCompare.filter("[productId='" + productId + "']").removeClass("selected");
		if (compareProductIds.length == 0) {
			$compareBar.fadeOut();
			removeCookie("compareProduct");
		} else {
			addCookie("compareProduct", compareProductIds.join(","));
		}
		return false;
	});
	
	$compareSubmit.click(function() {
		if (compareProductIds.length < 2) {
			$.alert("${message("shop.product.compareNotAllowed")}");
			return false;
		}
		
		$compareForm.submit();
		return false;
	});
	
	// 清除对比
	$clearCompare.click(function() {
		$addCompare.removeClass("selected");
		$compareBar.fadeOut().find("dd:not(.action)").remove();
		compareProductIds = [];
		removeCookie("compareProduct");
		return false;
	});
	
	// 添加对比
	$addCompare.click(function() {
		var $this = $(this);
		var productId = $this.attr("productId");
		if ($.inArray(productId, compareProductIds) >= 0) {
			return false;
		}
		if (compareProductIds.length >= 4) {
			$.alert("${message("shop.product.addCompareNotAllowed")}");
			return false;
		}
		$.ajax({
			url: "${base}/product/add_compare",
			type: "GET",
			data: {productId: productId},
			dataType: "json",
			success: function(data) {
				$this.addClass("selected");
				var thumbnail = data.thumbnail != null ? data.thumbnail : "${setting.defaultThumbnailProductImage}";
				$compareBar.show().find("dd.action").before(
					[@compress single_line = true]
						'<dd>
							<input type="hidden" name="productIds" value="' + data.id + '" \/>
							<a href="${base}' + escapeHtml(data.path) + '" target="_blank">
								<img src="' + escapeHtml(thumbnail) + '" \/>
								<span title="' + escapeHtml(data.name) + '">' + escapeHtml(abbreviate(data.name, 50)) + '<\/span>
							<\/a>
							<strong>' + currency(data.price, true) + '[#if setting.isShowMarketPrice]<del>' + currency(data.marketPrice, true) + '<\/del>[/#if]<\/strong>
							<a href="javascript:;" class="remove" productId="' + data.id + '">[${message("shop.common.remove")}]<\/a>
						<\/dd>'
					[/@compress]
				);
				compareProductIds.unshift(productId);
				addCookie("compareProduct", compareProductIds.join(","));
			}
		});
		return false;
	});
	
	$.pageSkip = function(pageNumber) {
		$pageNumber.val(pageNumber);
		$productForm.submit();
		return false;
	}

});
</script>
</head>
<body>
	[#include "/shop/include/header.ftl" /]
	<div class="container productList">
		<div id="compareBar" class="compareBar">
			<form action="${base}/product/compare" method="get">
				<dl>
					<dt>${message("shop.product.compareBar")}</dt>
					<dd class="action">
						<a href="javascript:;" class="submit">${message("shop.product.compareSubmit")}</a>
						<a href="javascript:;" class="clear">${message("shop.product.clearCompare")}</a>
					</dd>
				</dl>
			</form>
		</div>
		<div class="row">
			<div class="span2">
				[#include "/shop/include/hot_product_category.ftl" /]
				[#include "/shop/include/hot_brand.ftl" /]
				[#include "/shop/include/hot_product.ftl" /]
				[#include "/shop/include/hot_promotion.ftl" /]
			</div>
			<div class="span10">
				<div class="breadcrumb">
					<ul>
						<li>
							<a href="${base}/">${message("shop.breadcrumb.home")}</a>
						</li>
						[#if productCategory??]
							[@product_category_parent_list productCategoryId = productCategory.id]
								[#list productCategories as productCategory]
									<li>
										<a href="${base}${productCategory.path}">${productCategory.name}</a>
									</li>
								[/#list]
							[/@product_category_parent_list]
							<li>${productCategory.name}</li>
						[#else]
							<li>${message("shop.product.title")}</li>
						[/#if]
					</ul>
				</div>
				<form id="productForm" action="${base}${(productCategory.path)!"/product/list"}" method="get">
					<input type="hidden" id="brandId" name="brandId" value="${(brand.id)!}" />
					<input type="hidden" id="promotionId" name="promotionId" value="${(promotion.id)!}" />
					<input type="hidden" id="orderType" name="orderType" value="${orderType}" />
					<input type="hidden" id="pageNumber" name="pageNumber" value="${page.pageNumber}" />
					<input type="hidden" id="pageSize" name="pageSize" value="${page.pageSize}" />
					[#if productCategory??]
						[@product_category_children_list productCategoryId = productCategory.id recursive = false]
							[#assign filterProductCategories = productCategories /]
						[/@product_category_children_list]
						[@brand_list productCategoryId = productCategory.id]
							[#assign filterBrands = brands /]
						[/@brand_list]
						[@attribute_list productCategoryId = productCategory.id]
							[#assign filterAttributes = attributes /]
						[/@attribute_list]
						[#if filterProductCategories?has_content || filterBrands?has_content || filterAttributes?has_content]
							<div id="filter" class="filter">
								<div class="title">${message("shop.product.filter")}</div>
								<div class="content">
									[#assign rows = 0 /]
									[#if filterProductCategories?has_content]
										[#assign rows = rows + 1 /]
										<dl class="clearfix">
											<dt>${message("shop.product.productCategory")}:</dt>
											[#list filterProductCategories as filterProductCategory]
												<dd>
													<a href="${base}${filterProductCategory.path}">${filterProductCategory.name}</a>
												</dd>
											[/#list]
											<dd class="moreOption" title="${message("shop.product.moreOption")}">&nbsp;</dd>
										</dl>
									[/#if]
									[#if filterBrands?has_content]
										[#assign rows = rows + 1 /]
										<dl class="clearfix">
											<dt>${message("shop.product.brand")}:</dt>
											[#list filterBrands as filterBrand]
												<dd>
													<a href="javascript:;"[#if filterBrand == brand] class="brand current" title="${message("shop.product.cancel")}"[#else] class="brand"[/#if] brandId="${filterBrand.id}">${filterBrand.name}</a>
												</dd>
											[/#list]
											<dd class="moreOption" title="${message("shop.product.moreOption")}">&nbsp;</dd>
										</dl>
									[/#if]
									[#assign hasHiddenAttribute = false /]
									[#list filterAttributes as filterAttribute]
										[#assign rows = rows + 1 /]
										<dl class="clearfix[#if rows > 3 && !attributeValueMap?keys?seq_contains(filterAttribute)][#assign hasHiddenAttribute = true /] hidden[/#if]">
											<dt>
												<input type="hidden" name="attribute_${filterAttribute.id}"[#if attributeValueMap?keys?seq_contains(filterAttribute)] value="${attributeValueMap.get(filterAttribute)}"[#else] disabled="disabled"[/#if] />
												<span title="${filterAttribute.name}">${abbreviate(filterAttribute.name, 12)}:</span>
											</dt>
											[#list filterAttribute.options as option]
												<dd>
													<a href="javascript:;"[#if attributeValueMap.get(filterAttribute) == option] class="attribute current" title="${message("shop.product.cancel")}"[#else] class="attribute"[/#if]>${option}</a>
												</dd>
											[/#list]
											<dd class="moreOption" title="${message("shop.product.moreOption")}">&nbsp;</dd>
										</dl>
									[/#list]
								</div>
								<div id="moreFilter" class="moreFilter">
									[#if hasHiddenAttribute]
										<a href="javascript:;">${message("shop.product.moreFilter")}</a>
									[#else]
										&nbsp;
									[/#if]
								</div>
							</div>
						[/#if]
					[/#if]
					<div class="bar">
						<div id="layout" class="layout">
							<label>${message("shop.product.layout")}:</label>
							<a href="javascript:;" id="gridType" class="gridType">
								<span>&nbsp;</span>
							</a>
							<a href="javascript:;" id="listType" class="listType">
								<span>&nbsp;</span>
							</a>
							<label>${message("shop.product.pageSize")}:</label>
							<a href="javascript:;" class="size[#if page.pageSize == 20] current[/#if]" pageSize="20">
								<span>20</span>
							</a>
							<a href="javascript:;" class="size[#if page.pageSize == 40] current[/#if]" pageSize="40">
								<span>40</span>
							</a>
							<a href="javascript:;" class="size[#if page.pageSize == 80] current[/#if]" pageSize="80">
								<span>80</span>
							</a>
							<span class="page">
								<label>${message("shop.product.totalCount", page.total)} ${page.pageNumber}/[#if page.totalPages > 0]${page.totalPages}[#else]1[/#if]</label>
								[#if page.totalPages > 0]
									[#if page.pageNumber != 1]
										<a href="javascript:;" id="previousPage" class="previousPage">
											<span>${message("shop.product.previousPage")}</span>
										</a>
									[/#if]
									[#if page.pageNumber != page.totalPages]
										<a href="javascript:;" id="nextPage" class="nextPage">
											<span>${message("shop.product.nextPage")}</span>
										</a>
									[/#if]
								[/#if]
							</span>
						</div>
						<div id="sort" class="sort">
							<div id="orderMenu" class="orderMenu">
								[#if orderType??]
									<span>${message("Product.OrderType." + orderType)}</span>
								[#else]
									<span>${message("Product.OrderType." + orderTypes[0])}</span>
								[/#if]
								<ul>
									[#list orderTypes as type]
										<li[#if type == orderType] class="current"[/#if] orderType="${type}">${message("Product.OrderType." + type)}</li>
									[/#list]
								</ul>
							</div>
							<a href="javascript:;"[#if orderType == "priceAsc"] class="currentAsc current" title="${message("shop.product.cancel")}"[#else] class="asc"[/#if] orderType="priceAsc">${message("shop.product.priceAsc")}</a>
							<a href="javascript:;"[#if orderType == "salesDesc"] class="currentDesc current" title="${message("shop.product.cancel")}"[#else] class="desc"[/#if] orderType="salesDesc">${message("shop.product.salesDesc")}</a>
							<a href="javascript:;"[#if orderType == "scoreDesc"] class="currentDesc current" title="${message("shop.product.cancel")}"[#else] class="desc"[/#if] orderType="scoreDesc">${message("shop.product.scoreDesc")}</a>
							<input type="text" id="startPrice" name="startPrice" class="startPrice" value="${startPrice}" maxlength="16" title="${message("shop.product.startPrice")}" onpaste="return false" />
							<label>-</label>
							<input type="text" id="endPrice" name="endPrice" class="endPrice" value="${endPrice}" maxlength="16" title="${message("shop.product.endPrice")}" onpaste="return false" />
							<button type="submit">${message("shop.product.submit")}</button>
						</div>
					</div>
					<div id="result" class="result grid clearfix">
						[#if page.content?has_content]
							<ul>
								[#list page.content as product]
									[#assign defaultSku = product.defaultSku /]
									<li>
										<a href="${base}${product.path}">
											<img src="${base}/upload/image/blank.gif" data-original="${product.thumbnail!setting.defaultThumbnailProductImage}" />
											<div>
												[#if product.caption?has_content]
													<span title="${product.name}">${abbreviate(product.name, 24)}</span>
													<em title="${product.caption}">${abbreviate(product.caption, 24)}</em>
												[#else]
													${abbreviate(product.name, 48)}
												[/#if]
											</div>
										</a>
										<strong>
											[#if product.type == "general"]
												[#if currentUser == null] 
												   [#list product.productGrades as pg]
														[#if pg.grade.isDefault == true]
														   ${currency(pg.price, true)}
														[/#if]
												    [/#list]
												[#else]
													[#list product.productGrades as pg]
														[#if pg.grade.id == currentUser.memberRank.id]
														  ${currency(pg.price, true)}
														[/#if]
												    [/#list]
												[/#if]
												[#if setting.isShowMarketPrice]
													<del>${currency(defaultSku.marketPrice, true)}</del>
												[/#if]
											[#elseif product.type == "exchange"]
												<em>${message("Sku.exchangePoint")}:</em>
												${defaultSku.exchangePoint}
											[/#if]
                                            <!-- 券  -->
											[#if currentUser == null]

											[#else]
                                                <div style="font-size: 12px">
												${message("shop.index.coupon")}
												[#list product.productGrades as pg]
													[#if pg.grade.id == currentUser.memberRank.id]
													${pg.coupon}
													[/#if]
												[/#list]
                                                </div>
											[/#if]
										</strong>

										<div class=" action ">
											[#if permission == "permission"]
												[#if product.type == "general"]
													<a href="javascript:;" class="addCart" skuId="${defaultSku.id}">${message("shop.product.addCart")}</a>
												[#elseif product.type == "exchange"]
													<a href="javascript:;" class="exchange" skuId="${defaultSku.id}">${message("shop.product.exchange")}</a>
												[/#if]
											[/#if]
											<a href="javascript:;" class="addProductFavorite" title="${message("shop.product.addProductFavorite")}" productId="${product.id}">&nbsp;</a>
											[#--<a href="javascript:;" class="addCompare" title="${message("shop.product.addCompare")}" productId="${product.id}">&nbsp;</a>--]
										</div>
									</li>
								[/#list]
							</ul>
						[#else]
							[#noautoesc]
								${message("shop.product.noListResult")}
							[/#noautoesc]
						[/#if]
					</div>
					[@pagination pageNumber = page.pageNumber totalPages = page.totalPages pattern = "javascript: $.pageSkip({pageNumber});"]
						[#include "/shop/include/pagination.ftl"]
					[/@pagination]
				</form>
			</div>
		</div>
	</div>
	[#include "/shop/include/footer.ftl" /]
</body>
</html>
