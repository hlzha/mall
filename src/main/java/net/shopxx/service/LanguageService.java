package net.shopxx.service;

import java.util.List;

import net.shopxx.entity.Language;

/**
 * Service - 语言
 * 
 * @author gaoxiang
 * @version 5.0.3
 */
public interface LanguageService extends BaseService<Language, Long> {

	/**
	 * 查找所有的语言
	 * 
	 * @return 语言
	 */
	List<Language> find();

	Language findByCode(String code);
	
	Language findByLocale(String locale);
	
	Language getDefaultLanguage();
	
	Language setLanguage(Language language);
	
	void setLanguageSession(Language language);
}