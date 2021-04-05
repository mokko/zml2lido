<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!-- 1.1 objectMeasurementSet
	Contains information about the dimensions, or other measurements, of the
	object/work in focus; implies spacial, temporal or quantitative extent.
		measurementType
		measurementUnit
		measurementValue
	-->

	<xsl:template name="objectMeasurementsWrap">
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjDimAllGrp']/z:repeatableGroupItem"/>
    </xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjDimAllGrp']/z:repeatableGroupItem">
		<lido:objectMeasurementsSet>
			<lido:displayObjectMeasurements>
			<!-- use virtualField PreviewVrt and PreviewENVrt -->
			</lido:displayObjectMeasurements>
			<lido:objectMeasurements>
				<lido:measurementsSet>
					<lido:measurementUnit>
						<xsl:value-of select="z:vocabularyReference[@name='UnitDdiVoc']/z:vocabularyReferenceItem/@name"/>
					</lido:measurementUnit>
					<lido:measurementValue>
						<xsl:apply-templates select="z:moduleReference[@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue"/>
					</lido:measurementValue>
					<lido:measurementType>
						<xsl:value-of select="z:moduleReference[@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue"/>
					</lido:measurementType>
				</lido:measurementsSet>
			</lido:objectMeasurements>
		</lido:objectMeasurementsSet>
	</xsl:template>

	<xsl:template match="z:moduleReference[@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue">
		<xsl:choose>
			<xsl:when test=". = 'Objektmaß'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='DepthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Durchmesser'">
				<xsl:value-of select="../../z:dataField[@name='DiameterNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Durchmesser x Tiefe'">
				<xsl:value-of select="../../../z:dataField[@name='DiameterNum']/z:value"/>
				<xsl:value-of select="../../../z:dataField[@name='DepthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Gewicht'">
				<xsl:value-of select="../../../z:dataField[@name='WeightNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Höhe'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Höhe x Breite'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Höhe x Breite x Tiefe'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='DepthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Höhe x Durchmesser'">
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='DiameterNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Länge'">
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Länge x Breite x Höhe'">
				<xsl:value-of select="../../../z:dataField[@name='LengthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='HeightNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Länge x Breite x Tiefe'">
				<xsl:value-of select="../../../z:dataField[@name='DepthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='LengthNum']/z:value"/>
			</xsl:when>
			<xsl:when test=". = 'Länge x Durchmesser'">
				<xsl:value-of select="../../../z:dataField[@name='WidthNum']/z:value"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="../../../z:dataField[@name='DiameterNum']/z:value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>Unbekannter Maßtyp: </xsl:text>
					<xsl:value-of select="."/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>