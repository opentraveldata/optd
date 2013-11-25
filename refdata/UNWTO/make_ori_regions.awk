

##
#
BEGIN {
    region = ""
    subregion = ""

    country_map["UK"] = "GB"

    # Header
    print "User^Region^Sub-region^Country^Old code^Code^Country_code"
}

##
#
/^([A-Za-z]{1,20})\t/ {
    region = $1
}

##
#
/^([A-Za-z]{1,20}|)\t([A-Za-z, \-]{1,20})\t/ {
    subregion = $2
    # print region " / " subregion " for " $0
}


##
#
/^([A-Za-z]{1,20}|)\t([A-Za-z.,"& \-]{1,60}|)\t([A-Za-z.,"& \-\(\)]{1,60})\t/ {
    cnt_name = $3
    cnt_oldcode = $4
    cnt_code = $5
    country = substr(cnt_code,3,4)
    if (country in country_map)
        country = country_map[country]
    # print region "," subregion "," cnt_name "," cnt_oldcode "," cnt_code " for " $0
    print "UNWTO^" region "^" subregion "^" cnt_name "^" cnt_oldcode "^" cnt_code "^" country
}

