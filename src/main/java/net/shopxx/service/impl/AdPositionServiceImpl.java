/*
 * Copyright 2005-2017 shopxx.net. All rights reserved.
 * Support: http://www.shopxx.net
 * License: http://www.shopxx.net/license
 */
package net.shopxx.service.impl;

import java.util.List;

import javax.inject.Inject;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import net.shopxx.dao.AdPositionDao;
import net.shopxx.entity.AdPosition;
import net.shopxx.entity.Country;
import net.shopxx.service.AdPositionService;

/**
 * Service - 广告位
 * 
 * @author SHOP++ Team
 * @version 5.0.3
 */
@Service
public class AdPositionServiceImpl extends BaseServiceImpl<AdPosition, Long> implements AdPositionService {
	/**
	 * 查找文章分类树
	 * @param country
	 *            国家
	 * @return 文章分类树
	 */
	@Transactional(readOnly = true)
	public List<AdPosition> findTree(Country country){
		return adPositionDao.findChildren(country);
	}
	
	@Inject
	private AdPositionDao adPositionDao;

	@Transactional(readOnly = true)
	@Cacheable(value = "adPosition", condition = "#useCache")
	public AdPosition find(Long id, boolean useCache) {
		return adPositionDao.find(id);
	}
	@Transactional(readOnly = true)
	@Cacheable(value = "adPosition", condition = "#useCache")
	public AdPosition find(String orders, Country country,boolean useCache){
		return adPositionDao.find(orders,country);
	}
	@Override
	@Transactional
	@CacheEvict(value = "adPosition", allEntries = true)
	public AdPosition save(AdPosition adPosition) {
		return super.save(adPosition);
	}

	@Override
	@Transactional
	@CacheEvict(value = "adPosition", allEntries = true)
	public AdPosition update(AdPosition adPosition) {
		return super.update(adPosition);
	}

	@Override
	@Transactional
	@CacheEvict(value = "adPosition", allEntries = true)
	public AdPosition update(AdPosition adPosition, String... ignoreProperties) {
		return super.update(adPosition, ignoreProperties);
	}

	@Override
	@Transactional
	@CacheEvict(value = "adPosition", allEntries = true)
	public void delete(Long id) {
		super.delete(id);
	}

	@Override
	@Transactional
	@CacheEvict(value = "adPosition", allEntries = true)
	public void delete(Long... ids) {
		super.delete(ids);
	}

	@Override
	@Transactional
	@CacheEvict(value = "adPosition", allEntries = true)
	public void delete(AdPosition adPosition) {
		super.delete(adPosition);
	}

}