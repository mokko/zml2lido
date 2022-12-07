<xsl:stylesheet 
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:lido="http://www.lido-schema.org"
	xmlns:z="http://www.zetcom.com/ria/ws/module"
	xmlns:func="http://func"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd"
	exclude-result-prefixes="z func">

	<xsl:import href="zml2lido.xsl" />

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<!-- We are trying to inherit the whole xslt and change only one small part of it -->

	<!-- don't do anything for RIA's literatureRefs; i.e. overwrite stuff from objctRelationWrap-->
	<xsl:template match="z:moduleReference[@name='ObjLiteratureRef']/z:moduleReferenceItem"/>
	
</xsl:stylesheet>