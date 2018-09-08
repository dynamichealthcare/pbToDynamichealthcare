*** Settings ***
Library           Selenium2Library
Library           OperatingSystem
Library           String
Library           doFil.py
Variables         config/config.py
Variables         brands.py
Resource          Common.txt

*** Variables ***
${browser}        chrome

*** Test Cases ***
GetPB
    [Tags]    pb
    Remove Files    ${CURDIR}/img/*.*
    Comment    Set Global Variable    ${globalCounter}
    @{brands}=    Split String    ${PINKBLUEbrandsName2}    ,
    ${totBrands}=    Get Length    ${brands}
    : FOR    ${i}    IN RANGE    0    ${totBrands}
    \    GetPB_L1    ${${brands[${i}]}}    #${br1}

*** Keywords ***
GetPB_L1
    [Arguments]    ${url}
    ${br2}=    Open Browser    ${url}    ${browser}
    ${tmp}=    Get Text    //div[@class='column main']//div[@class='toolbar toolbar-products'][1]/p
    ${cnt}=    Fetch From Right    ${tmp}    ${SPACE}
    ${cnt}=    Run Keyword If    '${cnt}'=='Items'    Set Variable    1
    ...    ELSE IF    '${cnt}'=='Item'    Set Variable    1
    ...    ELSE    Convert To Number    ${cnt}
    ${cnt}=    Run Keyword If    ${cnt}>1    Evaluate    int(__import__('math').ceil( ${cnt}/36.0 )+2.0)
    ...    ELSE    SET VARIABLE    3
    Comment    ${cnt}=    Set variable    3
    : FOR    ${pg}    IN RANGE    2    ${cnt}
    \    ${medItems}=    Get Matching Xpath Count    //ol/li//div[@class='product details product-item-details']//a
    \    ${medItems}=    Evaluate    ${medItems}+1
    \    GetPB_L2    ${medItems}    ${br2}    #getItems
    \    Close Browser
    \    ${br2}=    Run Keyword If    ${pg}<${cnt}    Open Browser    ${url}?p=${pg}    ${browser}
    Switch Browser    ${br2}
    Close Browser
    Comment    Switch Browser    ${br1}

GetPB_L2
    [Arguments]    ${medItems}    ${br2}
    Comment    ${medItems}=    Set variable    11
    : FOR    ${INDEX}    IN RANGE    1    ${medItems}
    \    Run Keyword And Ignore Error    GetPB_L3    ${medItems}    ${br2}    ${INDEX}

GetPB_L3
    [Arguments]    ${medItems}    ${br2}    ${INDEX}
    ${url}=    Get Element Attribute    //ol/li[${INDEX}]//div[@class='product details product-item-details']//a    href
    ${br3}=    Open Browser    ${url}    ${browser}
    Wait Until Page Does Not Contain Element    //*[@alt='Loading...']    40s
    Sleep    3s
    ${pname}=    Get Text    //h1/span[@itemprop='name']
    ${pprice}=    Get Text    //span[@id='price-to-pay']
    ${pbrand}=    Get Text    //a[@id='brand']
    ${pbrand}=    Split String    ${pbrand}
    ${pcontStat}    ${pcontent}    Run Keyword And Ignore Error    Get Text    //div[@class='package-detail']
    ${pcontent}    Run Keyword If    '${pcontStat}'=='FAIL'    Set Variable    ${EMPTY}
    ...    ELSE    Set Variable    ${pcontent}
    ${pvariantsCount}=    Get Matching Xpath Count    //td[@data-th='Variant Name']
    ${pvariants}=    Set Variable    ${EMPTY}
    ${pvariants}=    Run Keyword If    ${pvariantsCount}>0    GetVariantNames    ${pvariantsCount}
    Log    ${pvariants}
    ${pvariants}=    Run Keyword If    '${pvariants}'=='None'    Set Variable    ${EMPTY}
    ...    ELSE    Set Variable    ${pvariants}
    ${pimgs}=    GetImages
    writeToFile    ${pname}::${pprice}::${pcontent}::${pvariants}::${pimgs}::${pbrand}
    Close Browser
    Switch Browser    ${br2}

writeToFile
    [Arguments]    ${data}
    Wait Until Keyword Succeeds    3m    1s    GetLock
    Run Keyword IF    ${fileLock}==0    Set Global Variable    ${fileLock}    1
    Run Keyword IF    ${fileLock}==1    Append To File    ${CURDIR}/../op2.txt    ${data}
    Run Keyword IF    ${fileLock}==1    Append To File    ${CURDIR}/../op2.txt    ${\n}
    Run Keyword IF    ${fileLock}==1    Set Global Variable    ${fileLock}    0

GetImages
    ${x}=    Set Variable    ${EMPTY}
    ${imgCount}=    Get Matching Xpath Count    //div[contains(@class,'fotorama__stage__shaft')]/div
    ${imgCount}=    Evaluate    ${imgCount}+1
    : FOR    ${i}    IN RANGE    1    ${imgCount}
    \    ${furl}=    Get Element Attribute    //div[contains(@class,'fotorama__stage__shaft')]/div[${i}]/img[@class='fotorama__img']    src
    \    ${filename}=    Getfilename    ${furl}
    \    doFil.File Download    ${furl}    ${filename}
    \    ${x}=    Run Keyword If    '${x}'=='${EMPTY}'    Set Variable    ${filename}
    \    ...    ELSE    Catenate    ${x}    |    ${filename}
    \    Comment    ${globalCounter}=    Evaluate    ${globalCounter}+1
    \    Comment    Set Global Variable    ${globalCounter}
    [Return]    ${x}
