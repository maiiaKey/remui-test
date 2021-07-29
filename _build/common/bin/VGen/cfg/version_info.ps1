#==============================================================================
# VersionInfo Language settings
#==============================================================================
$_langJoined_sk = "041B04E2"
$_lang_sk = "0x041B, 0x04E2"

$_langJoined_en = "040904E4"
$_lang_en = "0x0409, 0x04E4"

if ($_language -ieq "sk")
{
  $_langJoined = $_langJoined_sk
  $_lang = $_lang_sk
}
else
{
  $_langJoined = $_langJoined_en
  $_lang = $_lang_en
}

#==============================================================================
# VersionInfo body
#==============================================================================
$_versionInfo = "1 VERSIONINFO
 FILEVERSION $_majorVer,$_minorVer,$_releaseVer,$_buildVer
 PRODUCTVERSION $_majorVer,$_minorVer,$_releaseVer,0
 FILEOS 0x4L
 FILETYPE 0x1L
BEGIN
    BLOCK `"StringFileInfo`"
    BEGIN
        BLOCK `"$_langJoined`"
        BEGIN
            VALUE `"CompanyName`", `"$_companyName`"
            VALUE `"FileDescription`", `"$_fileDescription`"
            VALUE `"FileVersion`", `"$_majorVer.$_minorVer.$_releaseVer.$_buildVer`"
            VALUE `"InternalName`", `"$_internalName`"
            VALUE `"LegalCopyright`", `"$_copyright`"
            VALUE `"OriginalFilename`", `"$_originalFilename`"
            VALUE `"ProductName`", `"$_productName`"
            VALUE `"ProductVersion`", `"$_majorVer.$_minorVer.$_releaseVer`"
        END
    END
    BLOCK `"VarFileInfo`"
    BEGIN
        VALUE `"Translation`", $_lang
    END
END"

