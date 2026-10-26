<?xml version="1.0" encoding="utf-8"?>
<!--
  Order to JSON text (method="text"). XSLT 1.0 has no JSON output, so the map writes the text and escapes strings
  itself; the workflow turns the result into an object with json().
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="utf-8"/>

  <xsl:variable name="quote">"</xsl:variable>
  <xsl:variable name="backslash">\</xsl:variable>

  <xsl:template match="/Order">
    <xsl:text>{"orderNumber":</xsl:text>
    <xsl:call-template name="string"><xsl:with-param name="text" select="normalize-space(Number)"/></xsl:call-template>
    <xsl:text>,"customerId":</xsl:text>
    <xsl:call-template name="string"><xsl:with-param name="text" select="CustomerId"/></xsl:call-template>
    <xsl:text>,"orderDate":</xsl:text>
    <xsl:call-template name="string"><xsl:with-param name="text" select="OrderDate"/></xsl:call-template>
    <xsl:text>,"lines":[</xsl:text>
    <xsl:for-each select="Lines/Line">
      <xsl:if test="position() &gt; 1">,</xsl:if>
      <xsl:text>{"sku":</xsl:text>
      <xsl:call-template name="string"><xsl:with-param name="text" select="normalize-space(Sku)"/></xsl:call-template>
      <xsl:text>,"description":</xsl:text>
      <xsl:call-template name="string"><xsl:with-param name="text" select="Description"/></xsl:call-template>
      <xsl:text>,"quantity":</xsl:text>
      <xsl:value-of select="number(Quantity)"/>
      <xsl:text>,"unitPrice":</xsl:text>
      <xsl:value-of select="number(UnitPrice)"/>
      <xsl:text>}</xsl:text>
    </xsl:for-each>
    <xsl:text>],"units":</xsl:text>
    <xsl:value-of select="sum(Lines/Line/Quantity)"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- A JSON string: backslashes and double quotes are escaped. (Control characters are not expected in this data.) -->
  <xsl:template name="string">
    <xsl:param name="text"/>
    <xsl:variable name="escapedBackslashes">
      <xsl:call-template name="replace">
        <xsl:with-param name="text" select="$text"/>
        <xsl:with-param name="find" select="$backslash"/>
        <xsl:with-param name="with" select="concat($backslash, $backslash)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$quote"/>
    <xsl:call-template name="replace">
      <xsl:with-param name="text" select="string($escapedBackslashes)"/>
      <xsl:with-param name="find" select="$quote"/>
      <xsl:with-param name="with" select="concat($backslash, $quote)"/>
    </xsl:call-template>
    <xsl:value-of select="$quote"/>
  </xsl:template>

  <!-- XSLT 1.0 has no replace(): recurse on the first match. -->
  <xsl:template name="replace">
    <xsl:param name="text"/>
    <xsl:param name="find"/>
    <xsl:param name="with"/>
    <xsl:choose>
      <xsl:when test="contains($text, $find)">
        <xsl:value-of select="concat(substring-before($text, $find), $with)"/>
        <xsl:call-template name="replace">
          <xsl:with-param name="text" select="substring-after($text, $find)"/>
          <xsl:with-param name="find" select="$find"/>
          <xsl:with-param name="with" select="$with"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
