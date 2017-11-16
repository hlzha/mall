/*
 * Copyright 2005-2017 shopxx.net. All rights reserved.
 * Support: http://www.shopxx.net
 * License: http://www.shopxx.net/license
 */
package net.shopxx.controller.shop;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fasterxml.jackson.annotation.JsonView;

import net.shopxx.Results;
import net.shopxx.entity.BaseEntity;
import net.shopxx.entity.Cart;
import net.shopxx.entity.CartItem;
import net.shopxx.entity.Coupon;
import net.shopxx.entity.CouponCode;
import net.shopxx.entity.FiBankbookBalance;
import net.shopxx.entity.Invoice;
import net.shopxx.entity.Member;
import net.shopxx.entity.NapaStores;
import net.shopxx.entity.Order;
import net.shopxx.entity.PaymentMethod;
import net.shopxx.entity.Product;
import net.shopxx.entity.Receiver;
import net.shopxx.entity.ShippingMethod;
import net.shopxx.entity.Sku;
import net.shopxx.plugin.PaymentPlugin;
import net.shopxx.security.CurrentCart;
import net.shopxx.security.CurrentUser;
import net.shopxx.service.AreaService;
import net.shopxx.service.CouponCodeService;
import net.shopxx.service.FiBankbookBalanceService;
import net.shopxx.service.NapaStoresService;
import net.shopxx.service.OrderItemService;
import net.shopxx.service.OrderService;
import net.shopxx.service.PaymentMethodService;
import net.shopxx.service.PluginService;
import net.shopxx.service.ReceiverService;
import net.shopxx.service.ShippingMethodService;
import net.shopxx.service.SkuService;
import net.shopxx.util.SystemUtils;
import net.shopxx.util.WebUtils;

/**
 * Controller - 订单
 * 
 * @author SHOP++ Team
 * @version 5.0.3
 */
@Controller("shopOrderController")
@RequestMapping("/order")
public class OrderController extends BaseController {
	
	
	@Inject
	private SkuService skuService;
	@Inject
	private AreaService areaService;
	@Inject
	private ReceiverService receiverService;
	@Inject
	private PaymentMethodService paymentMethodService;
	@Inject
	private ShippingMethodService shippingMethodService;
	@Inject
	private CouponCodeService couponCodeService;
	@Inject
	private OrderService orderService;
	@Inject
	private PluginService pluginService;
	@Inject
	OrderItemService orderItemService;
	@Inject
	NapaStoresService napaStoresService;
	@Inject
	FiBankbookBalanceService fiBankbookBalanceService;
	/**
	 * 检查积分兑换
	 */
	@GetMapping("/check_exchange")
	public ResponseEntity<?> checkExchange(Long skuId, Integer quantity, @CurrentUser Member currentUser) {
		if (quantity == null || quantity < 1) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		Sku sku = skuService.find(skuId);
		if (sku == null) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (!Product.Type.exchange.equals(sku.getType())) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (!sku.getIsMarketable()) {
			return Results.unprocessableEntity("shop.order.skuNotMarketable");
		}
		if (quantity > sku.getAvailableStock()) {
			return Results.unprocessableEntity("shop.order.skuLowStock");
		}
		if (currentUser.getPoint() < sku.getExchangePoint() * quantity) {
			return Results.unprocessableEntity("shop.order.lowPoint");
		}
		return Results.OK;
	}

	/**
	 * 获取收货地址
	 */
	@GetMapping("/receiver_list")
	@JsonView(BaseEntity.BaseView.class)
	public ResponseEntity<?> receiverList(@CurrentUser Member currentUser) {
		return ResponseEntity.ok(receiverService.findList(currentUser));
	}

	/**
	 * 保存收货地址
	 */
	@PostMapping("/save_receiver")
	@JsonView(BaseEntity.BaseView.class)
	public ResponseEntity<?> saveReceiver(Receiver receiver, Long areaId, @CurrentUser Member currentUser) {
		receiver.setArea(areaService.find(areaId));
		if (!isValid(receiver)) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (Receiver.MAX_RECEIVER_COUNT != null && currentUser.getReceivers().size() >= Receiver.MAX_RECEIVER_COUNT) {
			return Results.unprocessableEntity("shop.order.addReceiverCountNotAllowed", Receiver.MAX_RECEIVER_COUNT);
		}
		receiver.setAreaName(null);
		receiver.setMember(currentUser);
		return ResponseEntity.ok(receiverService.save(receiver));
	}

	/**
	 * 获取订单锁
	 */
	@PostMapping("/acquire_lock")
	public @ResponseBody boolean acquireLock(String sn, @CurrentUser Member currentUser) {
		Order order = orderService.findBySn(sn);
		return order != null && currentUser.equals(order.getMember()) && orderService.acquireLock(order);
	}

	/**
	 * 检查等待付款
	 */
	@GetMapping("/check_pending_payment")
	public @ResponseBody boolean checkPendingPayment(String sn, @CurrentUser Member currentUser) {
		Order order = orderService.findBySn(sn);
		return order != null && currentUser.equals(order.getMember()) && order.getPaymentMethod() != null && PaymentMethod.Method.online.equals(order.getPaymentMethod().getMethod()) && order.getAmountPayable().compareTo(BigDecimal.ZERO) > 0;
	}

	/**
	 * 检查优惠券
	 */
	@GetMapping("/check_coupon")
	public ResponseEntity<?> checkCoupon(String code, @CurrentCart Cart currentCart) {
		Map<String, Object> data = new HashMap<>();
		if (currentCart == null || currentCart.isEmpty()) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (!currentCart.isCouponAllowed()) {
			return Results.unprocessableEntity("shop.order.couponNotAllowed");
		}
		CouponCode couponCode = couponCodeService.findByCode(code);
		if (couponCode != null && couponCode.getCoupon() != null) {
			Coupon coupon = couponCode.getCoupon();
			if (couponCode.getIsUsed()) {
				return Results.unprocessableEntity("shop.order.couponCodeUsed");
			}
			if (!coupon.getIsEnabled()) {
				return Results.unprocessableEntity("shop.order.couponDisabled");
			}
			if (!coupon.hasBegun()) {
				return Results.unprocessableEntity("shop.order.couponNotBegin");
			}
			if (coupon.hasExpired()) {
				return Results.unprocessableEntity("shop.order.couponHasExpired");
			}
			if (!currentCart.isValid(coupon)) {
				return Results.unprocessableEntity("shop.order.couponInvalid");
			}
			data.put("couponName", coupon.getName());
			return ResponseEntity.ok(data);
		} else {
			return Results.unprocessableEntity("shop.order.couponCodeNotExist");
		}
	}

	/**
	 * 结算
	 */
	@GetMapping("/checkout")
	public String checkout(@CurrentUser Member currentUser, @CurrentCart Cart currentCart, ModelMap model, RedirectAttributes redirectAttributes) {
		if (currentCart == null || currentCart.isEmpty()) {
			return "redirect:/cart/list";
		}
		if (currentCart.hasNotMarketable()) {
			addFlashMessage(redirectAttributes, "shop.order.hasNotMarketable");
			return "redirect:/cart/list";
		}
		List<PaymentMethod> paymentMethods = paymentMethodService.findAll();
		List<ShippingMethod> shippingMethods = shippingMethodService.findAll(currentUser.getCountry());
		PaymentMethod defaultPaymentMethod = CollectionUtils.isNotEmpty(paymentMethods) ? paymentMethods.get(0) : null;
		ShippingMethod defaultShippingMethod = null;
		if (defaultPaymentMethod != null) {
			for (ShippingMethod shippingMethod : shippingMethods) {
				if (CollectionUtils.isNotEmpty(shippingMethod.getPaymentMethods()) && shippingMethod.getPaymentMethods().contains(defaultPaymentMethod)) {
					defaultShippingMethod = shippingMethod;
					break;
				}
			}
		}
		Receiver defaultReceiver = receiverService.findDefault(currentUser);
		
		//区代
		NapaStores napaStores = currentUser.getNapaStores();
		
		//会员账户
		//List<FiBankbookBalance> fiBankbookBalance = fiBankbookBalanceService.findList(currentUser,null, 2, null, null);
		
		Order order = orderService.generate(Order.Type.general, currentCart,napaStores, defaultReceiver, defaultPaymentMethod, defaultShippingMethod, null, null, null, null);
		model.addAttribute("order", order);
		model.addAttribute("defaultReceiver", defaultReceiver);
		model.addAttribute("napaStores", napaStores);
		model.addAttribute("cartTag", currentCart.getTag());
		model.addAttribute("paymentMethods", paymentMethods);//支付方式
		model.addAttribute("fiBankbookBalance", fiBankbookBalanceService.find(currentUser,FiBankbookBalance.Type.balance));//会员余额账户
		model.addAttribute("fiBankbookCoupon", fiBankbookBalanceService.find(currentUser,FiBankbookBalance.Type.coupon));//会员余额账户

		model.addAttribute("shippingMethods", shippingMethods);//快递方式
		model.addAttribute("defaultPaymentMethod", defaultPaymentMethod);
		model.addAttribute("defaultShippingMethod", defaultShippingMethod);
		return "shop/order/checkout";
	}

	/**
	 * 结算
	 */
	@GetMapping(value = "/checkout", params = "type=exchange")
	public String checkout(Long skuId, Integer quantity, @CurrentUser Member currentUser, ModelMap model) {
		if (quantity == null || quantity < 1) {
			return UNPROCESSABLE_ENTITY_VIEW;
		}
		Sku sku = skuService.find(skuId);
		if (sku == null) {
			return UNPROCESSABLE_ENTITY_VIEW;
		}
		if (!Product.Type.exchange.equals(sku.getType())) {
			return UNPROCESSABLE_ENTITY_VIEW;
		}
		if (!sku.getIsMarketable()) {
			return UNPROCESSABLE_ENTITY_VIEW;
		}
		if (quantity > sku.getAvailableStock()) {
			return UNPROCESSABLE_ENTITY_VIEW;
		}
		if (currentUser.getPoint() < sku.getExchangePoint() * quantity) {
			return UNPROCESSABLE_ENTITY_VIEW;
		}
		CartItem cartItem = new CartItem();
		cartItem.setSku(sku);
		cartItem.setQuantity(quantity);
		Cart cart = new Cart();
		cart.setMember(currentUser);
		cart.add(cartItem);
		Receiver defaultReceiver = receiverService.findDefault(currentUser);
		
		//区代
		NapaStores napaStores = currentUser.getNapaStores();
		
		//会员账户
		//List<FiBankbookBalance> fiBankbookBalance = fiBankbookBalanceService.findList(currentUser,null, 2, null, null);
		
		Order order = orderService.generate(Order.Type.exchange, cart, napaStores ,defaultReceiver, null, null, null, null, null, null);
		model.addAttribute("skuId", skuId);
		model.addAttribute("quantity", quantity);
		model.addAttribute("order", order);
		model.addAttribute("defaultReceiver", defaultReceiver);
		model.addAttribute("paymentMethods", paymentMethodService.findAll());
		model.addAttribute("fiBankbookBalance", fiBankbookBalanceService.find(currentUser,FiBankbookBalance.Type.balance));//会员余额账户
		model.addAttribute("fiBankbookCoupon", fiBankbookBalanceService.find(currentUser,FiBankbookBalance.Type.coupon));//会员余额账户
		model.addAttribute("shippingMethods", shippingMethodService.findAll(currentUser.getCountry()));
		return "shop/order/checkout";
	}

	/**
	 * 计算
	 * 如果券和余额都充足则用余额，否则提示需要充值
	 */
	@GetMapping("/calculate")
	public ResponseEntity<?> calculate(Long receiverId, Long paymentMethodId, Long shippingMethodId, String code, String invoiceTitle, BigDecimal balance, String memo, @CurrentUser Member currentUser, @CurrentCart Cart currentCart) {
		Map<String, Object> data = new HashMap<>();
		if (currentCart == null || currentCart.isEmpty()) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		Receiver receiver = receiverService.find(receiverId);
		if (receiver != null && !currentUser.equals(receiver.getMember())) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (balance != null && balance.compareTo(BigDecimal.ZERO) < 0) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (balance != null && balance.compareTo(fiBankbookBalanceService.find(currentUser,FiBankbookBalance.Type.balance).getBalance()) > 0) {
			return Results.unprocessableEntity("shop.order.credit");
			//账户余额不足shop.order.insufficientBalance
		}

		PaymentMethod paymentMethod = paymentMethodService.find(paymentMethodId);
		ShippingMethod shippingMethod = shippingMethodService.find(shippingMethodId);
		CouponCode couponCode = couponCodeService.findByCode(code);
		Invoice invoice = StringUtils.isNotEmpty(invoiceTitle) ? new Invoice(invoiceTitle, null) : null;
		
		//区代
		NapaStores napaStores = currentUser.getNapaStores();
		
		Order order = orderService.generate(Order.Type.general, currentCart, napaStores ,receiver, paymentMethod, shippingMethod, couponCode, invoice, balance, memo);

		data.put("price", SystemUtils.changeCurrency(order.getPrice()));
		data.put("fee", SystemUtils.changeCurrency(order.getFee()));
		data.put("freight", SystemUtils.changeCurrency(order.getFreight()));
		data.put("tax", order.getTax());
		data.put("promotionDiscount", order.getPromotionDiscount());
		data.put("couponDiscount", SystemUtils.changeCurrency(order.getCouponDiscount()));
		data.put("amount", SystemUtils.changeCurrency(order.getAmount()));
		data.put("couponPrice", SystemUtils.changeCurrency(order.getCouponPrice()));
		data.put("amountPayable", SystemUtils.changeCurrency(order.getAmountPayable()));
		return ResponseEntity.ok(data);
	}

	/**
	 * 计算
	 */
	@GetMapping(path = "/calculate", params = "type=exchange")
	public ResponseEntity<?> calculate(Long skuId, Integer quantity, Long receiverId, Long paymentMethodId, Long shippingMethodId, BigDecimal balance, String memo, @CurrentUser Member currentUser) {
		Map<String, Object> data = new HashMap<>();
		if (quantity == null || quantity < 1) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		Sku sku = skuService.find(skuId);
		if (sku == null) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		Receiver receiver = receiverService.find(receiverId);
		if (receiver != null && !currentUser.equals(receiver.getMember())) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (balance != null && balance.compareTo(BigDecimal.ZERO) < 0) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (balance != null && balance.compareTo(fiBankbookBalanceService.find(currentUser,FiBankbookBalance.Type.balance).getBalance()) > 0) {
			return Results.unprocessableEntity("shop.order.insufficientBalance");
		}
		PaymentMethod paymentMethod = paymentMethodService.find(paymentMethodId);
		ShippingMethod shippingMethod = shippingMethodService.find(shippingMethodId);
		CartItem cartItem = new CartItem();
		cartItem.setSku(sku);
		cartItem.setQuantity(quantity);
		Cart cart = new Cart();
		cart.setMember(currentUser);
		cart.add(cartItem);
		
		//区代
		NapaStores napaStores = currentUser.getNapaStores();
		
		Order order = orderService.generate(Order.Type.general, cart, napaStores ,receiver, paymentMethod, shippingMethod, null, null, balance, null);

		data.put("price", SystemUtils.changeCurrency(order.getPrice()));
		data.put("fee", SystemUtils.changeCurrency(order.getFee()));
		data.put("freight", SystemUtils.changeCurrency(order.getFreight()));
		data.put("tax", order.getTax());
		data.put("promotionDiscount", order.getPromotionDiscount());
		data.put("couponDiscount", order.getCouponDiscount());
		data.put("amount", SystemUtils.changeCurrency(order.getAmount()));
		data.put("couponPrice", SystemUtils.changeCurrency(order.getCouponPrice()));
		data.put("amountPayable", SystemUtils.changeCurrency(order.getAmountPayable()));
		return ResponseEntity.ok(data);
	}

	/**
	 * 创建
	 */
	@PostMapping("/create")
	public ResponseEntity<?> create(String cartTag, 
									Long receiverId, 
									Long napaStoresId,
									Long paymentMethodId, 
									Long shippingMethodId, 
									String code, 
									String invoiceTitle, 
									BigDecimal balance, 
									BigDecimal coupon,
									String memo, 
									@CurrentUser Member currentUser, 
									@CurrentCart Cart currentCart) {
		Map<String, Object> data = new HashMap<>();

		if (currentCart == null || currentCart.isEmpty()) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (!StringUtils.equals(currentCart.getTag(), cartTag)) {
			return Results.unprocessableEntity("shop.order.cartHasChanged");
		}
		if (currentCart.hasNotMarketable()) {
			return Results.unprocessableEntity("shop.order.hasNotMarketable");
		}
		if (currentCart.getIsLowStock()) {
			return Results.unprocessableEntity("shop.order.cartLowStock");
		}
		Receiver receiver = null;
		//区代
		NapaStores napaStores = napaStoresService.find(napaStoresId);
		if(napaStores == null || !currentUser.getNapaStores().equals(napaStores)){
			return Results.UNPROCESSABLE_ENTITY;
		}
		
		//判断是不是首单
		List<Order> orders = orderService.findPage(null, null, currentUser, null, null, null, null, null, null, null, null).getContent();
		if(orders.size() > 0){//不是首单
			if (balance == null || balance.compareTo(currentUser.getMemberRank().getNextSingle()) < 0) {
				return Results.unprocessableEntity("shop.order.nextSingle",currentUser.getMemberRank().getNextSingle());
			}
		}else{//首单
			if (balance == null || balance.compareTo(currentUser.getMemberRank().getFirstSingle()) < 0) {
				return Results.unprocessableEntity("shop.order.fristSingle",currentUser.getMemberRank().getFirstSingle());
			}
		}
		ShippingMethod shippingMethod = null;
		PaymentMethod paymentMethod = paymentMethodService.find(paymentMethodId);
		if (currentCart.getIsDelivery()) {
			
			if(currentUser.getMemberRank().getType().name().equals("register")){
				receiver = receiverService.find(receiverId);
				if (receiver == null || !currentUser.equals(receiver.getMember())) {
					return Results.UNPROCESSABLE_ENTITY;
				}
			}
			
			shippingMethod = shippingMethodService.find(shippingMethodId);
			if (shippingMethod == null) {
				return Results.UNPROCESSABLE_ENTITY;
			}
		}
		CouponCode couponCode = couponCodeService.findByCode(code);
		if (couponCode != null && !currentCart.isValid(couponCode)) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (balance == null || balance.compareTo(BigDecimal.ZERO) < 0) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		
		if (balance == null || balance.compareTo(fiBankbookBalanceService.find(currentUser,FiBankbookBalance.Type.balance).getBalance()) > 0) {
			return Results.unprocessableEntity("shop.order.insufficientBalance");
		}
		if (coupon == null || coupon.compareTo(BigDecimal.ZERO) < 0) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (coupon == null || coupon.compareTo(fiBankbookBalanceService.find(currentUser,FiBankbookBalance.Type.coupon).getBalance()) > 0) {
			return Results.unprocessableEntity("shop.order.insufficientCoupon");
		}
		Invoice invoice = StringUtils.isNotEmpty(invoiceTitle) ? new Invoice(invoiceTitle, null) : null;
		Order order = orderService.createNose(Order.Type.general, currentCart, receiver,napaStores, paymentMethod, shippingMethod, couponCode, invoice, balance,coupon, memo);
		
		data.put("sn", order.getSn());
		//发送订单接口
		//String ss = orderService.orderInterface(order);
		//System.out.println(ss);
		
		return ResponseEntity.ok(data);
	}

	/**
	 * 创建
	 */
	@PostMapping(path = "/create", params = "type=exchange")
	public ResponseEntity<?> create(Long skuId, 
									Integer quantity, 
									Long receiverId,
									Long napaStoresId, 
									Long paymentMethodId, 
									Long shippingMethodId, 
									BigDecimal balance, 
									BigDecimal coupon, 
									String memo, @CurrentUser Member currentUser) {
		Map<String, Object> data = new HashMap<>();

		if (quantity == null || quantity < 1) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		Sku sku = skuService.find(skuId);
		if (sku == null) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (!Product.Type.exchange.equals(sku.getType())) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (!sku.getIsMarketable()) {
			return Results.unprocessableEntity("shop.order.skuNotMarketable");
		}
		if (quantity > sku.getAvailableStock()) {
			return Results.unprocessableEntity("shop.order.skuLowStock");
		}
		Receiver receiver = null;
		
		//区代
		NapaStores napaStores = napaStoresService.find(napaStoresId);
		if(napaStores == null || !currentUser.getNapaStores().equals(napaStores)){
			return Results.UNPROCESSABLE_ENTITY;
		}
		
		//判断是不是首单
		List<Order> orders = orderService.findPage(null, null, currentUser, null, null, null, null, null, null, null, null).getContent();
		if(orders.size() > 0){//不是首单
			//System.out.println(balance.compareTo(currentUser.getMemberRank().getNextSingle()));
			if (balance == null || balance.compareTo(currentUser.getMemberRank().getNextSingle()) < 0) {
				return Results.unprocessableEntity("shop.order.nextSingle",currentUser.getMemberRank().getNextSingle());
			}
		}else{//首单
			if (balance == null || balance.compareTo(currentUser.getMemberRank().getFirstSingle()) < 0) {
				return Results.unprocessableEntity("shop.order.fristSingle",currentUser.getMemberRank().getFirstSingle());
			}
		}
		
		ShippingMethod shippingMethod = null;
		PaymentMethod paymentMethod = paymentMethodService.find(paymentMethodId);
		if (sku.getIsDelivery()) {
			/*receiver = receiverService.find(receiverId);
			if (receiver == null || !currentUser.equals(receiver.getMember())) {
				return Results.UNPROCESSABLE_ENTITY;
			}*/
			shippingMethod = shippingMethodService.find(shippingMethodId);
			if (shippingMethod == null) {
				return Results.UNPROCESSABLE_ENTITY;
			}
		}
		if (currentUser.getPoint() < sku.getExchangePoint() * quantity) {
			return Results.unprocessableEntity("shop.order.lowPoint");
		}
		if (balance == null || balance.compareTo(fiBankbookBalanceService.find(currentUser,FiBankbookBalance.Type.balance).getBalance()) > 0) {
			return Results.unprocessableEntity("shop.order.insufficientBalance");
		}
		if (coupon == null || coupon.compareTo(BigDecimal.ZERO) < 0) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		if (coupon == null || coupon.compareTo(fiBankbookBalanceService.find(currentUser,FiBankbookBalance.Type.coupon).getBalance()) > 0) {
			return Results.unprocessableEntity("shop.order.insufficientCoupon");
		}
		CartItem cartItem = new CartItem();
		cartItem.setSku(sku);
		cartItem.setQuantity(quantity);
		Cart cart = new Cart();
		cart.setMember(currentUser);
		cart.add(cartItem);

		Order order = orderService.createNose(Order.Type.exchange, cart, receiver,napaStores, paymentMethod, shippingMethod, null, null, balance,coupon, memo);
		
		data.put("sn", order.getSn());
		return ResponseEntity.ok(data);
	}

	/**
	 * 支付
	 */
	@GetMapping("/payment")
	public String payment(String orderSn, @CurrentUser Member currentUser, ModelMap model, RedirectAttributes redirectAttributes) {
		Order order = orderService.findBySn(orderSn);
		if (order == null || !currentUser.equals(order.getMember()) || order.getPaymentMethod() == null || order.getAmountPayable().compareTo(BigDecimal.ZERO) <= 0) {
			return UNPROCESSABLE_ENTITY_VIEW;
		}
		if (PaymentMethod.Method.online.equals(order.getPaymentMethod().getMethod())) {
			if (!orderService.acquireLock(order)) {
				addFlashMessage(redirectAttributes, "shop.order.locked");
				return "redirect:/member/order/view?orderSn=" + order.getSn() + "";
			}
			List<PaymentPlugin> paymentPlugins = pluginService.getActivePaymentPlugins(WebUtils.getRequest());
			if (CollectionUtils.isNotEmpty(paymentPlugins)) {
				PaymentPlugin defaultPaymentPlugin = paymentPlugins.get(0);
				model.addAttribute("fee", defaultPaymentPlugin.calculateFee(order.getAmountPayable()));
				model.addAttribute("amount", defaultPaymentPlugin.calculateAmount(order.getAmountPayable()));
				model.addAttribute("couponPrice", defaultPaymentPlugin.calculateCouponPrice(order.getCouponPrice()));
				model.addAttribute("defaultPaymentPlugin", defaultPaymentPlugin);
				model.addAttribute("paymentPlugins", paymentPlugins);
			}
		}
		model.addAttribute("order", order);
		return "shop/order/payment";
	}

	/**
	 * 计算支付金额
	 */
	@GetMapping("/calculate_amount")
	public ResponseEntity<?> calculateAmount(String paymentPluginId, String sn, @CurrentUser Member currentUser) {
		Map<String, Object> data = new HashMap<>();
		Order order = orderService.findBySn(sn);
		PaymentPlugin paymentPlugin = pluginService.getPaymentPlugin(paymentPluginId);
		if (order == null || !currentUser.equals(order.getMember()) || paymentPlugin == null || !paymentPlugin.getIsEnabled()) {
			return Results.UNPROCESSABLE_ENTITY;
		}
		data.put("fee", paymentPlugin.calculateFee(order.getAmountPayable()));
		data.put("amount", paymentPlugin.calculateAmount(order.getAmountPayable()));
		return ResponseEntity.ok(data);
	}

}