*** Settings ***
Documentation                                       HB Case Study
Library                                             Collections
Library                                             Selenium2Library
Library                                             String
Suite Teardown                                      Quit Browser

*** Variables ***
${url}              https://www.hepsiburada.com/
${browser}          chrome

*** Test Cases ***
Test Case 1
    Given Open Browser and Setup
    When Search                     bluetooth kulaklık
    Then Filter Search - By Brand    JBL
    And Filter Search - By Price (Min - Max)    500    1500
    And Filter Search - By Color    Siyah
    And Click first product from search page
    And Product Page - Add product to basket
    And Check Basket Page

*** Keywords ***
Open Browser and Setup
    # Disable notifications
    ${options}=    Evaluate  sys.modules['selenium.webdriver.chrome.options'].Options()    sys
    Call Method     ${options}    add_argument    --disable-notifications
    # Start driver with chrome browser, hepsiburada as base url and given options above
    open browser               ${url}    ${browser}    options=${options}
    maximize browser window

Search
    [Arguments]  ${keyword}
    input text  xpath=//input[@type='text']    ${keyword}
    sleep    2
    press keys    id=SearchBoxOld    ENTER
    wait until page contains element    css=.product-list
    ${search_result}    get text    xpath=//h1[@class='searchResultSummaryBar-bold']
    log to console    ->
    log to console    Searched Product: ${search_result}

Filter Search - By Brand
    [Arguments]  ${brand}
    input text    xpath=(//input[@class='searchbox-searchInput'])[1]      ${brand}
    sleep    2
    scroll to "xpath=(//div[@class='content-label'])[1]" element
    click element    xpath=(//div[@class='content-label'])[1]
    log to console    Filtering with the Brand: ${brand}
    wait until element is visible    xpath=//a[contains(.,'Filtreleri temizle')]
    wait until element is visible    xpath=//div[@class='FacetList-header'][contains(.,'Marka')]
    ${filter_count}      get element count    xpath=//div[@class='FacetList-header']
    log to console    Selected Filter Count: ${filter_count}
    should be equal as integers    ${filter_count}    1

Filter Search - By Price (Min - Max)
    [Arguments]  ${min}    ${max}
    # Close cookie bar if appears
    ${present}=  Run Keyword And Return Status    Element Should Be Visible   css=.cookie-info
    Run Keyword If    ${present}    Close cookie bar
    input text    xpath=//input[@placeholder='En az']      ${min}
    input text    xpath=//input[@placeholder='En çok']     ${max}
    click element    xpath=//button[@kind='primary']
    wait until element is visible    xpath=//a[contains(.,'Filtreleri temizle')]
    wait until element is visible    xpath=//div[@class='FacetList-header'][contains(.,'Fiyat Aralığı')]
    log to console    Filtering by Price - Interval: ${min} - ${max}
    ${filter_count}      get element count    xpath=//div[@class='FacetList-header']
    log to console    Selected Filter Count: ${filter_count}
    should be equal as integers    ${filter_count}    2

Filter Search - By Color
    [Arguments]  ${color}
    Scroll to "xpath=//div[@data-test-id='collapse-title'][contains(.,'Renk')]" element
    click element    xpath=//div[@data-test-id='collapse-title'][contains(.,'Renk')]
    sleep    1
    Scroll to top
    Scroll to "xpath=//div[@data-test-id='collapse-title'][contains(.,'Renk')]" element
    click element    xpath=//div[@class='content-label content-forceFlex'][contains(.,'${color}')]
    Scroll to top
    log to console    Filtering By Color: ${color}
    wait until element is visible    xpath=//a[contains(.,'Filtreleri temizle')]
    sleep    5
    wait until element is visible    xpath=//div[@class='FacetList-header'][contains(.,'Renk')]
    ${filter_count}      get element count    xpath=//div[@class='FacetList-header']
    log to console    Selected Filter Count: ${filter_count}
    should be equal as integers    ${filter_count}    3

Close cookie bar
    click element    css=body > div.cookie-info > img

Click first product from search page
    reload page
    wait until element is visible    css=.productListContent-root
    ${products}    get webelements   css=h3
    click element  ${products[0]}

Product Page - Add product to basket
    ${handles}=    Get Window Handles
    Switch Window    ${handles}[1]
    log    Swithing tabs since product page opens in new tab
    wait until page contains element    css=.product-name
    element should be visible    css=.owl-item    Product Carousel Container Area NOT Visible
    click button    id=addToCart
    wait until element is visible    xpath=//span[contains(.,'Ürün sepetinizde')]
    click button    xpath=//button[contains(.,'Sepete git')]

Check Basket Page
    wait until location contains    checkout
    wait until element is visible    xpath=//button[@id='continue_step_btn']
    ${Basket_Header}=    get text   xpath=//h1[contains(.,'Sepetim')]
    should be equal as strings    ${Basket_Header}    Sepetim    Basket Header NOT True

Scroll to "${Element}" element
    wait until element is visible  ${Element}
    ${Height}    Get Vertical Position    ${Element}
    ${Height}    convert to integer    ${Height}
    ${Height}    evaluate    ${Height}+150
    Execute Javascript  window.scrollTo(0, ${Height})
    sleep    2

Scroll to top
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)

Quit Browser
    close all browsers