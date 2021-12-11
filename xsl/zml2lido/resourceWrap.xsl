<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
	xmlns:func="http://func"
    exclude-result-prefixes="z func"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<xsl:template name="resourceWrap">
        <xsl:variable name="objId" select="z:systemField[@name='__id']" />
        <xsl:variable name="verknüpfteMM" select="/z:application/z:modules/z:module[@name = 'Multimedia']
			/z:moduleItem[
				 z:composite[@name = 'MulReferencesCre']
					/z:compositeItem/z:moduleReference[@name = 'MulObjectRef']
					/z:moduleReferenceItem[@moduleItemId = $objId]
				and	z:repeatableGroup[@name = 'MulApprovalGrp']
					/z:repeatableGroupItem/z:vocabularyReference[@instanceName='MulApprovalTypeVgr']
					/z:vocabularyReferenceItem[@name ='SMB-digital']
				and z:repeatableGroup[@name = 'MulApprovalGrp']
					/z:repeatableGroupItem/z:vocabularyReference[@instanceName='MulApprovalVgr']
					/z:vocabularyReferenceItem[@name ='Ja']
		]"/>

		<!--xsl:message>
			<xsl:value-of select="$objId"/>
			<xsl:text>:::</xsl:text>
			<xsl:for-each select="$verknüpfteMM">
				<xsl:value-of select="z:systemField[@name='__id']"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="z:systemField[@name='__id']"/>
			</xsl:for-each>
		</xsl:message-->
			<xsl:if test="$verknüpfteMM">
				<lido:resourceWrap>
					<xsl:apply-templates mode="resourceWrap" select="$verknüpfteMM" />
				</lido:resourceWrap>
			</xsl:if>
    </xsl:template>

    <xsl:template mode="resourceWrap" match="/z:application/z:modules/z:module[@name = 'Multimedia']/z:moduleItem">
		<xsl:variable name="objId" select="z:composite[@name eq 'MulReferencesCre']/z:compositeItem/z:moduleReference[1]/z:moduleReferenceItem/@moduleItemId"/>
		<xsl:variable name="verwaltendeInstitution" select="/z:application/z:modules/z:module[
			@name = 'Object']/z:moduleItem[@id = $objId]/z:moduleReference[
			@name='ObjOwnerRef']/z:moduleReferenceItem/z:formattedValue"/>
		<!--xsl:message>resourceSet</xsl:message-->
        <lido:resourceSet>
			<!--
				xsl:nummer nummeriert alle verknüpfteMM durch; das geht so nicht
				wo steht die Info, was ein Standardbild ist
			-->
            <xsl:attribute name="lido:sortorder">
				<xsl:variable name="sort" select="z:composite[@name='MulReferencesCre']/z:compositeItem/z:moduleReference[
					@name= 'MulObjectRef']/z:moduleReferenceItem/z:dataField[
					@name='SortLnu']/z:value"/>
				<!--xsl:message> ex objId 214875
					why I do get multiple SortLnu values sometimes; just using the first one atm
					<xsl:text>SORT:::</xsl:text>
					<xsl:value-of select="$sort"/>
				</xsl:message-->
				<xsl:choose>
					<xsl:when test="$sort[1] ne ''">
						<xsl:value-of select="$sort[1]"/>
					</xsl:when>
					<xsl:otherwise>10</xsl:otherwise>
				</xsl:choose>
            </xsl:attribute>
            <lido:resourceID>
				<xsl:attribute name="lido:label">Bild</xsl:attribute>
				<xsl:attribute name="lido:type">mulId</xsl:attribute>
				<xsl:attribute name="lido:source">SMB/ObjID/AssetID</xsl:attribute> 
				<xsl:value-of select="func:getISIL($verwaltendeInstitution)" />
				<xsl:text>/</xsl:text>
				<xsl:value-of select="$objId" />
				<xsl:text>/</xsl:text>
				<xsl:value-of select="z:systemField[@name='__id']/z:value" />
            </lido:resourceID>
			
            <!-- according to LIDO's pdf specification resourceID can have
                 attribute encodinganalog; according to xsd it can't have 
                 it. 
                <xsl:attribute name="encodinganalog">
                    <xsl:value-of select="pfadangabe"/>
                    <xsl:text>\</xsl:text>
                    <xsl:value-of select="dateiname"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="erweiterung"/>
                </xsl:attribute>
            -->
            <lido:resourceRepresentation>
                <xsl:attribute name="lido:type" xml:lang="EN">
					<xsl:text>Provided image</xsl:text>
					<!--xsl:analyze-string select="z:dataField[@name='MulOriginalFileTxt']" regex=".(\w*)$">
						<xsl:matching-substring>
							xsl:message>
								<xsl:text>EXT</xsl:text>
								<xsl:value-of select="regex-group(1)"/>
							</xsl:message
							<xsl:choose>
								<xsl:when test="lower-case(regex-group(1)) eq 'jpg'">
									<xsl:text>Preview image</xsl:text>
								</xsl:when>
								<xsl:when test="lower-case(regex-group(1)) eq 'tif' or lower-case(regex-group(1)) eq 'tiff' ">
									<xsl:text>Provided image</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>Preview image</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:matching-substring>
					</xsl:analyze-string-->
                </xsl:attribute>
				<xsl:variable name="id" select="normalize-space(z:systemField[@name='__id']/z:value)" />
                <lido:linkResource> 
					<xsl:analyze-string select="z:dataField[@name='MulOriginalFileTxt']" regex=".(\w*)$">
						<xsl:matching-substring>
							<xsl:attribute name="lido:formatResource">
								<xsl:value-of select="func:vocmap-replace('formatResource', lower-case(regex-group(1)), 'mimetype')"/>
							</xsl:attribute>
							<!-- https://recherche.smb.museum/images/525075_2500x2500.jpg
							<xsl:value-of select="concat('https://recherche.smb.museum/images/',$id,'_2500x2500.jpg')"/>
							-->
							<xsl:value-of select="concat($id,'.',regex-group(1))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
                </lido:linkResource>
                    <!-- lido:resourceMeasurementsSet>
                        <lido:measurementType>width</lido:measurementType>
                        <lido:measurementUnit>pixel</lido:measurementUnit>
                        <lido:measurementValue>120</lido:measurementValue>
                    </lido:resourceMeasurementsSet -->
            </lido:resourceRepresentation>
			<lido:resourceType>
				<!-- 
					lido spec 1.0 "Example values: digital image, photograph, slide, videotape, Xray
					photograph, negative."
					no voc at http://terminology.lido-schema.org 20200301
					TODO
				-->
				<xsl:comment>type="europeana:type"</xsl:comment>
				<xsl:variable name="resType" select="z:vocabularyReference[@name='MulTypeVoc']/z:vocabularyReferenceItem/@name"/>
				<xsl:variable name="euType" select="func:vocmap-replace('MulTypeVgr',$resType, 'europeana:type')"/>

				<!-- 
					<xsl:message>
						resType: <xsl:value-of select="$resType"/> :: <xsl:value-of select="$euType"/>
					</xsl:message>
					default to image, so make sure we ALWAYS have a europeana:type
				-->
				<lido:term xml:lang="EN">
					<xsl:choose>
						<xsl:when test="$euType ne ''">
								<xsl:value-of select="$euType"/>
						</xsl:when>
						<xsl:otherwise>
								<xsl:text>image</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</lido:term>
			</lido:resourceType>
			<xsl:apply-templates select="z:dataField[@name='MulSubjectTxt']/z:value"/>
			<xsl:apply-templates select="z:dataField[@name='MulDateTxt']/z:value"/>
			<!--Urheber-->
			<xsl:apply-templates mode="Urheber" select="z:moduleReference[@name='MulPhotographerPerRef']"/>
			
            <lido:rightsResource>
				<lido:rightsType>
					<lido:conceptID lido:source="CC"
					                lido:type="URI">http://creativecommons.org/by-nc-sa/4.0/</lido:conceptID>
					<lido:term lido:addedSearchTerm="no">Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)</lido:term>
				</lido:rightsType>                
				<lido:rightsHolder>
					<xsl:call-template name="legalBody">
						<xsl:with-param name="verwaltendeInstitution" select="z:moduleReference[@name='ObjOwnerRef']"/>
					</xsl:call-template>
                </lido:rightsHolder>

                <!-- 
                TODO: Not sure how FD wants the the creditline to be formated; 
                Currently, I am adapting credits in smb.digital.de, but not exactly. 
				Should be Staatliche Museen Berlin, Kunstbibliothek, Foto: Hans Kunz
                -->
                <lido:creditLine>
					<xsl:variable name="einrichtung" select="normalize-space(substring-before($verwaltendeInstitution,','))"/>
					<!-- can also be SIM in case of MIM -->
					<xsl:variable name="smb" select="normalize-space(substring-after($verwaltendeInstitution,','))"/>
					<xsl:value-of select="$smb"/>
					<xsl:text>, </xsl:text>
					<xsl:value-of select="$einrichtung"/>
                    <xsl:if test="z:moduleReference[@name='MulPhotographerPerRef']">
                        <xsl:text>, Foto: </xsl:text>
                        <xsl:value-of select="z:moduleReference[@name='MulPhotographerPerRef']/z:moduleReferenceItem/z:formattedValue"/>
                    </xsl:if>
                </lido:creditLine>
            </lido:rightsResource>
        </lido:resourceSet>
    </xsl:template>

    <xsl:template mode="Urheber" match="z:moduleReference[@name='MulPhotographerPerRef']">
		<!--xsl:message>
			<xsl:text>Urheber</xsl:text>
			<xsl:value-of select="z:moduleReferenceItem/z:formattedValue" />
		</xsl:message-->
		<lido:rightsResource>
			<lido:rightsType>
				<lido:term xml:lang="DE">Urheber</lido:term>
			</lido:rightsType>
			<lido:rightsHolder>
				<lido:legalBodyName>
					<lido:appellationValue>
						<xsl:value-of select="z:moduleReferenceItem/z:formattedValue" />
					</lido:appellationValue>
				</lido:legalBodyName>
			</lido:rightsHolder>
		</lido:rightsResource>
    </xsl:template>

	<!--inhaltAnsicht-->
    <xsl:template match="z:dataField[@name='MulSubjectTxt']/z:value">
		<lido:resourceDescription>
			<xsl:value-of select="."/>
		</lido:resourceDescription>
	</xsl:template>

    <!-- 
		was:anfertDat
        resourceDateTaken is part of xsd, given in LIDO examples, but not 
        part in pdf specification -->
    <xsl:template match="z:dataField[@name='MulDateTxt']/z:value">
        <lido:resourceDateTaken>
            <lido:displayDate>
                <xsl:value-of select="."/>
            </lido:displayDate>
        </lido:resourceDateTaken> 
    </xsl:template>
</xsl:stylesheet>
