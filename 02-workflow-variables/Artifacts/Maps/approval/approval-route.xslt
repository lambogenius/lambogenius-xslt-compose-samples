<?xml version="1.0" encoding="utf-8"?>
<!--
  Decides how an order is handled: "reject" without lines, "review" when the total is over $threshold, else "auto".
  The workflow stores the answer in a variable and switches on it.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    exclude-result-prefixes="msxsl">
  <xsl:output method="text" encoding="utf-8"/>

  <xsl:param name="threshold" select="100"/>

  <xsl:template match="/Order">
    <xsl:variable name="amounts">
      <xsl:for-each select="Lines/Line">
        <amount><xsl:value-of select="Quantity * UnitPrice"/></amount>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="total" select="sum(msxsl:node-set($amounts)/amount)"/>
    <xsl:choose>
      <xsl:when test="not(Lines/Line)">reject</xsl:when>
      <xsl:when test="$total &gt; $threshold">review</xsl:when>
      <xsl:otherwise>auto</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
