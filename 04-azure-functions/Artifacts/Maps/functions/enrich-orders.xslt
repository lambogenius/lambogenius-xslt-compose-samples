<?xml version="1.0" encoding="utf-8"?>
<!--
  Adds each order's customer name from the GetCustomerName Function. No scripts are needed to call Functions.
  The registry sets cacheWithinTransform, so a customer that appears twice in one batch is looked up once.
  An unknown customer makes the Function answer 404, and the whole action fails with FunctionHttpFailed: a map
  never receives an empty value in place of an error.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="urn:lambogenius:azure-functions"
    exclude-result-prefixes="fn">

  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="/Batch">
    <Orders count="{count(Order)}">
      <xsl:for-each select="Order">
        <Order number="{Number}">
          <CustomerId><xsl:value-of select="CustomerId"/></CustomerId>
          <CustomerName><xsl:value-of select="fn:InvokeText('GetCustomerName', string(CustomerId))"/></CustomerName>
        </Order>
      </xsl:for-each>
    </Orders>
  </xsl:template>

  <!-- A single order works too. -->
  <xsl:template match="/Order">
    <Orders count="1">
      <Order number="{normalize-space(Number)}">
        <CustomerId><xsl:value-of select="CustomerId"/></CustomerId>
        <CustomerName><xsl:value-of select="fn:InvokeText('GetCustomerName', string(CustomerId))"/></CustomerName>
      </Order>
    </Orders>
  </xsl:template>
</xsl:stylesheet>
