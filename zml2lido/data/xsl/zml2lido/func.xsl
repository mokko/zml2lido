<xsl:stylesheet 
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:lido="http://www.lido-schema.org"
	xmlns:z="http://www.zetcom.com/ria/ws/module"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:func="http://func"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd"
	exclude-result-prefixes="z func fn">

	<!-- 
		Man kann die ISIL in MuseumPlus unter der PK-DS der verwaltenden Institution im Register Normdaten nachgucken
	-->
	<xsl:function name="func:getISIL">
		<xsl:param name="verwaltendeInstitution"/>
		<xsl:value-of select="func:vocmap-replace('verwaltendeInstitution', $verwaltendeInstitution, 'ISIL')" />
	</xsl:function>

	<xsl:function name="func:getISIL2">
		<!-- get ISIL based on Bereich-->
		<xsl:param name="orgUnit"/>
		<xsl:value-of select="func:vocmap-replace('Bereich', $orgUnit, 'ISIL')" />
	</xsl:function>

	<xsl:function name="func:reformatDate">
		<!-- 
			takes input in format [{\d|\d\d}\.[{\d|\d\d}\.]]\d{1-4} 
			and returns YYYY[-MM[-DD]] according to LIDO spec 1.0.
	
			TODO: now limitation is with negative years which fits the ISO 8601 quite well
			
			Wikipedia about ISO 8601's treatment of years: "ISO 8601 prescribes, as a minimum, 
			a four-digit year [YYYY] to avoid the year 2000 problem. It therefore represents years 
			from 0000 to 9999, year 0000 being equal to 1 BC and all others AD. However, years 
			before 1583 are not automatically allowed by the standard. Instead 'values in the 
			range [0000] through [1582] shall only be used by mutual agreement of the partners in 
			information interchange.'"

			LIDO Spec also mentions  time, but haven't encountered that yet.
			
			Accepts only a single value, no sequence - which, emphatically, is a feature not a bug.
		-->
		<xsl:param name="date"/>
		<!--xsl:message>
			<xsl:value-of select="$date"/>
			<xsl:text> [</xsl:text>
			<xsl:value-of select="count($date)"/>
			<xsl:text>]</xsl:text>
		</xsl:message-->

		<xsl:variable name="date2" select="normalize-space($date)"/>
		<!-- what about years before 0? -->
		<xsl:variable name="y" select="analyze-string($date2, '(\d|\d\d|\d{3}|\d{4})$')//fn:match/fn:group[@nr = 1]"/>
		<xsl:variable name="m" select="analyze-string($date2, '(\d|\d\d)\.\d+$')//fn:match/fn:group[@nr = 1]"/>
		<xsl:variable name="d" select="analyze-string($date2, '^(\d|\d\d)\.\d+\.\d+')//fn:match/fn:group[@nr = 1]"/>

		<xsl:variable name="yyyy">
			<xsl:if test="$y ne ''">
				<xsl:value-of select="format-number(number($y),'0000')"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="mm">
			<xsl:if test="$m ne ''">
				<xsl:value-of select="format-number(number($m),'00')"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="dd">
			<xsl:if test="$d ne ''">
				<xsl:value-of select="format-number(number($d),'00')"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="new">
			<xsl:value-of select="$yyyy"/>
			<xsl:if test="$mm ne ''">
				<xsl:text>-</xsl:text>
				<xsl:value-of select="$mm"/>
			</xsl:if>
			<xsl:if test="$dd ne ''">
			<xsl:text>-</xsl:text>
			<xsl:value-of select="$dd"/>
			</xsl:if>
		</xsl:variable>
		<!-- xsl:message>
			<xsl:text> reformatDate: </xsl:text>
			<xsl:value-of select="$date" />
			<xsl:text> :: </xsl:text>
			<xsl:value-of select="$new" />
		</xsl:message-->
		<xsl:value-of select="$new" />
	</xsl:function>
	
	<xsl:function name="func:vocmap-replace">
		<xsl:param name="src-voc"/>
		<xsl:param name="src-term"/>
		<xsl:param name="target"/>
		<xsl:variable name="dict" select="document('file:zml2lido/data/vocmap.xml')"/>
		<!-- used to be eq; unclear why now =. There should be only one match. With = i get schema error. -->
		<xsl:variable name="return" select="$dict/vocmap/voc[@name eq $src-voc]/concept[source = $src-term]/target[@name eq $target]/text()"/>
		<!-- die if replacement returns empty, except if source is already empty -->
		<xsl:if test="normalize-space($return) = '' and normalize-space($src-term) != ''">
			<xsl:message terminate="yes">
				<xsl:text>ERROR: vocmap-replace returns EMPTY ON </xsl:text>
				<xsl:value-of select="$src-term"/> 
				<xsl:text> FROM </xsl:text>
				<xsl:value-of select="$src-voc"/> 
			</xsl:message>
		</xsl:if> 
		<xsl:value-of select="$return"/>
	</xsl:function>

	<!-- 
		there might be cases where it is not an ERROR to return NONE after vocmap lookup
		this is the same as normal vocmap-replace, only with terminate="no"
	-->
	<xsl:function name="func:vocmap-replace-lax">
		<xsl:param name="src-voc"/>
		<xsl:param name="src-term"/>
		<xsl:param name="target"/>
		<xsl:variable name="dict" select="document('file:zml2lido/data/vocmap.xml')"/>
		<!-- used to be eq; unclear why now =. There should be only one match. With = i get schema error. -->
		<xsl:variable name="return" select="$dict/vocmap/voc[@name eq $src-voc]/concept[source = $src-term]/target[@name eq $target]/text()"/>
		<xsl:if test="normalize-space($return) = '' and normalize-space($src-term) != ''">
			<xsl:message terminate="no">
				<xsl:text>WARNING: vocmap-replace-lax returns EMPTY ON </xsl:text>
				<xsl:value-of select="$src-term"/> 
				<xsl:text> FROM </xsl:text>
				<xsl:value-of select="$src-voc"/> 
			</xsl:message>
		</xsl:if> 
		<xsl:value-of select="$return"/>
	</xsl:function>

	<xsl:function name="func:weblink">
		<xsl:param name="verwaltendeInstitution"/>
		<xsl:value-of select="func:vocmap-replace('verwaltendeInstitution', $verwaltendeInstitution, 'homepage')" />
	</xsl:function>
</xsl:stylesheet>