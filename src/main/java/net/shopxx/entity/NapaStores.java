package net.shopxx.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.Entity;

import org.hibernate.validator.constraints.Length;
@Entity
public class NapaStores extends BaseEntity<Long>{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**
	 * 区代编号
	 */
	@Length(max = 200)
	@Column(nullable = true,name="napa_code")
	private String napaCode;
	
	/**
	 * 余额
	 */
	@Column(nullable = true, precision = 27, scale = 12)
	private BigDecimal balance;
	/**
	 * 电话
	 */
	@Length(max = 200)
	private String mobile;
	/**
	 * 地址
	 */
	@Length(max = 200)
	@Column(nullable = true,name="napa_address")
	private String napaAddress;
	
	/**
	 * 类型，type=0,1,2,3,5 ：注册用户，代理商，服务中心，加盟店，中心店
	 */
	@Length(max = 2)
	@Column(columnDefinition=" default 1")
	private int type;
	
	/**
	 * 区代类型
	 * @return
	 */
	public int getType() {
		return type;
	}
	/**
	 * 区代类型
	 * @return
	 */
	public void setType(int type) {
		this.type = type;
	}
	/**
	 * 获取区代编号
	 */
	public String getNapaCode() {
		return napaCode;
	}
	/**
	 * set区代编号
	 */
	public void setNapaCode(String napaCode) {
		this.napaCode = napaCode;
	}
	/**
	 * 获取余额
	 */
	public BigDecimal getBalance() {
		return balance;
	}
	/**
	 * 存入余额
	 */
	public void setBalance(BigDecimal balance) {
		this.balance = balance;
	}
	/**
	 * 获取地址
	 * @return
	 */
	public String getNapaAddress() {
		return napaAddress;
	}
	/**
	 * 设置地址
	 * @param napaAddress
	 */
	public void setNapaAddress(String napaAddress) {
		this.napaAddress = napaAddress;
	}
	/**
	 * 电话
	 */
	public String getMobile() {
		return mobile;
	}
	/**
	 * 电话
	 */
	public void setMobile(String mobile) {
		this.mobile = mobile;
	}
}
