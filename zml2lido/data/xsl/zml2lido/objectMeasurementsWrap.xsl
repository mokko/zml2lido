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
		<lido:objectMeasurementsWrap>
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjDimAllGrp']/z:repeatableGroupItem"/>
		</lido:objectMeasurementsWrap>
    </xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjDimAllGrp']/z:repeatableGroupItem">
		<lido:objectMeasurementsSet>
			<xsl:if test="normalize-space(z:virtualField[@name='PreviewVrt']/z:value) != ''">
				<lido:displayObjectMeasurements xml:lang="de">
					<xsl:value-of select="normalize-space(z:moduleReference[
						@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue)"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="normalize-space(z:virtualField[@name='PreviewVrt']/z:value)"/>
				</lido:displayObjectMeasurements>
			</xsl:if>

			<xsl:if test="normalize-space(z:virtualField[@name='PreviewENVrt']/z:value) != ''">
				<lido:displayObjectMeasurements xml:lang="en">
					<xsl:value-of select="normalize-space(z:virtualField[@name='PreviewENVrt']/z:value)"/>
				</lido:displayObjectMeasurements>
			</xsl:if>

			<lido:objectMeasurements>
				<xsl:variable name="value">
					<xsl:apply-templates select="z:moduleReference[
						@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue" mode="value"/>
				</xsl:variable>
				<lido:measurementsSet>
					<lido:measurementType xml:lang="de">
						<xsl:value-of select="normalize-space(z:moduleReference[
							@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue)"/>
					</lido:measurementType>
					<lido:measurementUnit xml:lang="de">
						<xsl:value-of select="normalize-space(z:vocabularyReference[
							@name='UnitDdiVoc']/z:vocabularyReferenceItem/@name)"/>
					</lido:measurementUnit>
					<lido:measurementValue xml:lang="de">
						<xsl:value-of select="translate ($value, '.',',')"/>
					</lido:measurementValue>
				</lido:measurementsSet>
				<lido:measurementsSet>
					<lido:measurementType xml:lang="de">
						<xsl:value-of select="normalize-space(z:moduleReference[
							@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue)"/>
					</lido:measurementType>
					<lido:measurementUnit xml:lang="en">
						<xsl:value-of select="normalize-space(z:vocabularyReference[
							@name='UnitDdiVoc']/z:vocabularyReferenceItem/@name)"/>
					</lido:measurementUnit>
					<lido:measurementValue xml:lang="en">
						<xsl:value-of select="$value"/>
					</lido:measurementValue>
				</lido:measurementsSet>

			</lido:objectMeasurements>
		</lido:objectMeasurementsSet>
	</xsl:template>

	<xsl:template mode="value" match="z:moduleReference[@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue">
		<xsl:variable name="this" select="normalize-space(.)"/>
		<xsl:choose>
			<xsl:when test="$this eq 'Andere Maße'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown3Num']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown1Num']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown2Num']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Auflagekarton'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Außenmaß'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Allgemein'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown1Num']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown2Num']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Bemalte Bildfläche'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Bildformat (Foto)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Bildmaß'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Blattmaß'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Breite'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Breite x Tiefe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Dauer'">
				<xsl:value-of select="format-number(../../../z:dataField[@name='HoursLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='MinutesLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='SecondsLnu']/z:value, '00')"/>
			</xsl:when>
			<!--todo: no value; might need correction upstream in RIA -->
			<xsl:when test="$this eq 'Diaformat'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='ThicknessNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Dicke'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='ThicknessNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Durchmesser'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Durchmesser (mit Dicke)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='ThicknessNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Durchmesser x Tiefe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Fläche'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown1Num']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Format'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='PrefixTxt']/z:value)"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='SuffixTxt']/z:value)"/>
			</xsl:when>
			<!-- Walze ist unnötig; todo: in RIA korrigieren -->
			<xsl:when test="$this eq 'Geschwindigkeit'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='SpeedNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Geschwindigkeit (Band)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='SpeedNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Geschwindigkeit (Schallplatte)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='SpeedNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Geschwindigkeit (Walze)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='SpeedNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Gewicht'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Höhe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Höhe x Breite'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Höhe x Breite (aufgeschlagen)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Höhe x Breite x Stärke'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='ThicknessNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Höhe x Breite x Tiefe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Höhe x Durchmesser'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Kartonformat'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Kartonformat (Foto)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Kistenmaß'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Länge'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Länge x Breite'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Länge x Breite x Höhe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Länge x Breite x Tiefe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Länge x Durchmesser'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Mündung'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Negativformat (Foto)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
			</xsl:when>			
			<xsl:when test="$this eq 'Montage'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='LengthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Objektmaß'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Öffnung'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Passepartout'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Passepartoutmaß'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Passepartout Standardformat'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>			
			<xsl:when test="$this eq 'Plattengröße (Foto)'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Rahmenmaß'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Rahmenaußenmaß'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Sehnenlänge'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown1Num']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Sockel'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
			</xsl:when>
			<!-- Spieldauer is synonymous with Dauer; replace with pref in RIA-->
			<xsl:when test="$this eq 'Spieldauer'">
				<xsl:value-of select="format-number(../../../z:dataField[@name='HoursLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='MinutesLnu']/z:value, '00')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="format-number(../../../z:dataField[@name='SecondsLnu']/z:value, '00')"/>
			</xsl:when>
			<!-- only instance of Stichmaß has no value; todo-->
			<xsl:when test="$this eq 'Stichmaß'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='Unknown1Num']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Tiefe'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Transportmaß'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Umfang'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='CircumferenceNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Verpackungsmaß'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='WidthNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='HeightNum']/z:value)"/>
				<xsl:text> x </xsl:text>
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DepthNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Volumen'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='VolumeNum']/z:value)"/>
			</xsl:when>
			<xsl:when test="$this eq 'Wandstärke' or  . = 'Wandungsstärke'">
				<xsl:value-of select="normalize-space(../../../z:dataField[@name='DiameterNum']/z:value)"/>
			</xsl:when>
			<!-- DONT OUTPUT ANYTHING, BUT DONT DIE EITHER-->
			<xsl:when test="$this eq 'Leer'"/>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>ERROR: Unknown measurement type: </xsl:text>
					<xsl:value-of select="."/>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="../../../../../../@name"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="../../../../../@id"/>
					<xsl:text>)</xsl:text>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>