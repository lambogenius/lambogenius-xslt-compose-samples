<?xml version="1.0" encoding="utf-8"?>
<!--
  Order to invoice. Every parameter comes from a workflow variable:
    $currency  string   (string variable)
    $taxRate   number   (float variable)
    $expedite  boolean  (boolean variable), so <xsl:if test="$expedite"> works as expected
    $maxLines  number   (integer variable): only the first $maxLines lines are invoiced
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    exclude-result-prefixes="msxsl">

  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="yes"/>

  <xsl:param name="currency" select="'CAD'"/>
  <xsl:param name="taxRate" select="0"/>
  <xsl:param name="expedite" select="false()"/>
  <xsl:param name="maxLines" select="100"/>

  <xsl:template match="/Order">
    <xsl:variable name="lines" select="Lines/Line[position() &lt;= $maxLines]"/>
    <xsl:variable name="amounts">
      <xsl:for-each select="$lines">
        <amount><xsl:value-of select="Quantity * UnitPrice"/></amount>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="subtotal" select="round(sum(msxsl:node-set($amounts)/amount) * 100) div 100"/>
    <xsl:variable name="shipping">
      <xsl:choose>
        <xsl:when test="$expedite">15</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="tax" select="round(($subtotal + $shipping) * $taxRate * 100) div 100"/>

    <Invoice currency="{$currency}">
      <OrderNumber><xsl:value-of select="translate(normalize-space(Number), 'ord', 'ORD')"/></OrderNumber>
      <Shipping>
        <xsl:attribute name="method">
          <xsl:choose>
            <xsl:when test="$expedite">Express</xsl:when>
            <xsl:otherwise>Standard</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="format-number($shipping, '0.00')"/>
      </Shipping>
      <Lines count="{count($lines)}" of="{count(Lines/Line)}">
        <xsl:for-each select="$lines">
          <Line sku="{translate(normalize-space(Sku), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')}">
            <xsl:value-of select="format-number(Quantity * UnitPrice, '0.00')"/>
          </Line>
        </xsl:for-each>
      </Lines>
      <Subtotal><xsl:value-of select="format-number($subtotal, '0.00')"/></Subtotal>
      <Tax rate="{$taxRate}"><xsl:value-of select="format-number($tax, '0.00')"/></Tax>
      <Total><xsl:value-of select="format-number($subtotal + $shipping + $tax, '0.00')"/></Total>
    </Invoice>
  </xsl:template>
</xsl:stylesheet>
