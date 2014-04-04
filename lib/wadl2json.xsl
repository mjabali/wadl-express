<?xml version="1.0"?>

<!--

An XSL stylesheet to transform WADL files as defined in "Web Application Description Language,
W3C Member Submission 31 August 2009" to an intermediate JSON format that has all references
resolved for easier client consumption.

WADL Support: 

Complete: 

* Intra-document cross-referencing (WADL Spec 2.1).
* Documentation with proper JSON/HTML escaping (WADL Spec 2.3).
* Resources (WADL Spec 2.5)
* Resource Type (WADL Spec 2.7).
* Method (WADL Spec 2.8, 2.8.1, 2.8.2).
* Request (WADL Spec 2.9, 2.9.1).
* Response (WADL Spec 2.10).
 
Incomplete: 

* Application (WADL Spec 2.2), everything except grammars.
* Resource (WADL Spec 2.6): everything, but only a single type yet (no whitespace-separated list).
* Representation (WADL Spec 2.11): everything except child params (2.11.3). 
* Parameter: everything except links (2.12.4).

Not supported:

* Inter-document cross-referencing (WADL Spec 2.1).
* Grammar elements (WADL Spec 2.4, 2.4.1).
* Proper XML handling (types).

-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:wadl="http://research.sun.com/wadl/2006/10">

	<xsl:output method="text"/>

	<!-- WADL Spec 2.2 -->
	<xsl:template match="/wadl:application">{
		"docs": [<xsl:call-template name="docs"/>]
		,"grammars": [<!-- <xsl:call-template name="grammars"/> -->]
		,"resources": [<xsl:for-each select="wadl:resources"><xsl:apply-templates select="."/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>]
	}</xsl:template>

	<!-- WADL Spec 2.5 -->
	<xsl:template match="wadl:resources">
		{"baseUrl": "<xsl:value-of select="@base"/>"
		,"resources": [<xsl:for-each select=".//wadl:resource"><xsl:call-template name="resource"/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>]}
	</xsl:template>

	<!-- WADL Spec 2.6 -->
	<xsl:template match="wadl:resource" name="resource">
		<xsl:choose>
			<xsl:when test="@type">
				{"path": "<xsl:value-of select="@path"/>"
				,"fullPath": <xsl:call-template name="resource-path"/>
				<xsl:if test="@id">,"id": "<xsl:value-of select="@id"/>"</xsl:if>
				<xsl:if test="@type">,"type": "<xsl:value-of select="@type"/>"</xsl:if>
				<xsl:if test="@queryType">,"queryType": "<xsl:value-of select="@queryType"/>"</xsl:if>
				,"docs": [<xsl:for-each select="wadl:doc|/wadl:application/wadl:resource_type[@id=current()/@type]/wadl:doc"><xsl:apply-templates select="."/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>]
				,"params": [<xsl:for-each select="wadl:param[not(@style='query') and(not(@style='header'))]|/wadl:application/wadl:resource_type[@id=current()/@type]/wadl:param[@style='query' or @style='header']"><xsl:apply-templates select="."/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>]
				,"methods": [<xsl:for-each select="wadl:method|/wadl:application/wadl:resource_type[@id=current()/@type]/wadl:method"><xsl:apply-templates select="."/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>]}
			</xsl:when>
			<xsl:otherwise>
				{"path": "<xsl:value-of select="@path"/>"
				,"fullPath": <xsl:call-template name="resource-path"/>
				<xsl:if test="@id">,"id": "<xsl:value-of select="@id"/>"</xsl:if>
				<xsl:if test="@type">,"type": "<xsl:value-of select="@type"/>"</xsl:if>
				<xsl:if test="@queryType">,"queryType": "<xsl:value-of select="@queryType"/>"</xsl:if>
				,"docs": [<xsl:for-each select="wadl:doc"><xsl:apply-templates select="."/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>]
				,"params": [<xsl:call-template name="parameters"/>]
				,"methods": [<xsl:call-template name="methods"/>]}	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="resource-path">[<xsl:for-each select="ancestor::wadl:resource">"<xsl:value-of select="@path"/>",</xsl:for-each>"<xsl:value-of select="@path"/>"]</xsl:template>

	<!--  WADL Spec 2.12.2 -->
	<xsl:template name="parameters">
		<xsl:for-each select="wadl:param">{<xsl:call-template name="wadl:param"/>}<xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>
	</xsl:template>

	<!--  WADL Spec 2.12.2 -->
	<xsl:template match="wadl:param" name="wadl:param">
		<xsl:choose>
				<xsl:when test="@href">
					<xsl:apply-templates select="//wadl:param[@id=current()/@href]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="param"><xsl:with-param name="attr">name</xsl:with-param></xsl:call-template>
					,<xsl:call-template name="param"><xsl:with-param name="attr">id</xsl:with-param></xsl:call-template>
					,<xsl:call-template name="param"><xsl:with-param name="attr">href</xsl:with-param></xsl:call-template>
					,<xsl:call-template name="param"><xsl:with-param name="attr">style</xsl:with-param></xsl:call-template>
					,<xsl:call-template name="param"><xsl:with-param name="attr">type</xsl:with-param></xsl:call-template>
					,<xsl:call-template name="param"><xsl:with-param name="attr">default</xsl:with-param></xsl:call-template>
					,<xsl:call-template name="param"><xsl:with-param name="attr">required</xsl:with-param><xsl:with-param name="type">boolean</xsl:with-param></xsl:call-template>
					,<xsl:call-template name="param"><xsl:with-param name="attr">repeating</xsl:with-param><xsl:with-param name="type">boolean</xsl:with-param></xsl:call-template>
					,<xsl:call-template name="param"><xsl:with-param name="attr">fixed</xsl:with-param></xsl:call-template>
						<xsl:if test="wadl:option">,<xsl:call-template name="options"/></xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--  WADL Spec 2.12.2 -->
	<xsl:template name="param"><xsl:param name="attr"/><xsl:param name="type"/>"<xsl:value-of select="$attr"/>": <xsl:choose><xsl:when test="$type!='boolean'">"<xsl:value-of select="attribute::*[name()=$attr]"/>"</xsl:when><xsl:otherwise><xsl:choose><xsl:when test="attribute::*[name()=$attr]">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose></xsl:otherwise></xsl:choose></xsl:template>

	<!-- WADL Spec 2.12.3 -->
	<xsl:template name="options">"options":[<xsl:for-each select="wadl:option"><xsl:call-template name="attribute-list"/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>]</xsl:template>

	<!--  WADL Spec 2.8 -->
	<xsl:template match="wadl:method">
		<xsl:choose>
			<xsl:when test="@href">
				<xsl:apply-templates select="//wadl:method[@id=current()/@href]"/>
			</xsl:when>
			<xsl:otherwise>
			{"name": "<xsl:value-of select="@name"/>"
			,"docs": [<xsl:call-template name="docs"/>]
			,"request": {<xsl:apply-templates select="wadl:request[1]"/>}
			,"responses": [<xsl:call-template name="responses"/>]}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--  WADL Spec 2.8 -->
	<xsl:template name="methods">
		<xsl:for-each select="wadl:method">
			<xsl:apply-templates select="."/>
			<xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>
	</xsl:template>

	<!--  WADL Spec 2.9 -->
	<xsl:template match="wadl:request">"params": [
		<xsl:for-each select="ancestor-or-self::wadl:*[local-name()='resource' or local-name()='request' or local-name()='response'][wadl:param]"><xsl:call-template name="parameters"/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>], "representations":[<xsl:call-template name="representations"/>], "docs":[<xsl:call-template name="docs"/>]</xsl:template>

	<!-- WADL Spec 2.11 -->
	<xsl:template name="representations">
		<xsl:for-each select="wadl:representation">
			<xsl:choose>
				<xsl:when test="@href">
					<xsl:apply-templates select="//wadl:representation[@id=current()/@href]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="."/>
				</xsl:otherwise>
			</xsl:choose><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>
	</xsl:template>

	<!-- WADL Spec 2.11 -->
	<xsl:template match="wadl:representation">
		<xsl:call-template name="attribute-list"/>
	</xsl:template>

	<!--  WADL Spec 2.10 -->
	<xsl:template name="responses">
		<xsl:for-each select="wadl:response"><xsl:apply-templates select="."/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>
	</xsl:template>

	<!--  WADL Spec 2.10 -->
	<xsl:template match="wadl:response">{
		"representations":[<xsl:call-template name="representations"/>]
		,"docs":[<xsl:call-template name="docs"/>]
		,"params": [<xsl:call-template name="parameters"/>]
		<xsl:if test="@status">"status":"<xsl:value-of select="@status"/>"</xsl:if>
	}</xsl:template>

	<!--  WADL Spec 2.3 -->
	<xsl:template name="docs"><xsl:for-each select="wadl:doc"><xsl:apply-templates select="."/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each></xsl:template>

	<xsl:template match="wadl:doc">{"content":"<xsl:apply-templates mode="serialize"/>","lang":"<xsl:value-of select="@xml:lang"/>"}</xsl:template>

  	<xsl:template match="*" mode="serialize">
  		<xsl:variable name="empty-html-elements">area,base,br,col,command,embed,hr,img,input,keygen,link,meta,param,source,track,wbr</xsl:variable>
  		<xsl:choose>
  			<xsl:when test="contains($empty-html-elements, local-name())">&lt;<xsl:value-of select="name()"/><xsl:apply-templates select="@*" mode="serialize"/>/&gt;</xsl:when>
  			<xsl:otherwise>&lt;<xsl:value-of select="name()"/><xsl:apply-templates select="@*" mode="serialize"/>&gt;<xsl:apply-templates mode="serialize"/>&lt;/<xsl:value-of select="name()"/>&gt;</xsl:otherwise>
  		</xsl:choose>
  	</xsl:template>

  	<xsl:template match="@*" mode="serialize">
  		<xsl:text> </xsl:text><xsl:value-of select="name()"/>=\"<xsl:value-of select="string()"/>\"</xsl:template>

  	<xsl:template match="text()" mode="serialize"><xsl:call-template name="escape-doc"/></xsl:template>

  	<xsl:template name="escape-doc">
		<xsl:variable name="t1"><xsl:call-template name="string-replace-all">
			<xsl:with-param name="text" select="."/>
			<xsl:with-param name="replace" select="'&#10;'"/>
			<xsl:with-param name="by" select="'\n'"/>
		</xsl:call-template></xsl:variable>
		<xsl:variable name="t2"><xsl:call-template name="string-replace-all">
			<xsl:with-param name="text" select="$t1"/>
			<xsl:with-param name="replace" select="'&#34;'"/>
			<xsl:with-param name="by" select="'\&#34;'"/>
		</xsl:call-template></xsl:variable>
		<xsl:value-of select="$t2"/>
  	</xsl:template>

  	<xsl:template name="string-replace-all">
		<xsl:param name="text"/>
		<xsl:param name="replace"/>
		<xsl:param name="by"/>
		<xsl:choose>
			<xsl:when test="contains($text, $replace)">
				<xsl:value-of select="substring-before($text,$replace)"/>
				<xsl:value-of select="$by"/>
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="substring-after($text,$replace)"/>
					<xsl:with-param name="replace" select="$replace"/>
					<xsl:with-param name="by" select="$by"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="attribute-list">
		{<xsl:for-each select="@*">"<xsl:value-of select="name()"/>": "<xsl:value-of select="string()"/>"<xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>}
	</xsl:template>

	<xsl:template match="text()"></xsl:template>

</xsl:stylesheet>