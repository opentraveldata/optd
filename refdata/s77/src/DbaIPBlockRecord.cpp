// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// STL
#include <string>
#include <exception>
// Opengeopp
#include "DbaIPBlockRecord.hpp"

namespace soci {

  // //////////////////////////////////////////////////////////////////////
  void type_conversion<OPENGEOPP::IPBlockRecord_T>::
  from_base (values const& iIPBlockRecordValues, indicator /* ind */,
             OPENGEOPP::IPBlockRecord_T& ioIPBlockRecord) {
    /*
      ip_from, ip_to, registry, assigned_date,
      country_code_2, country_code_3, country_name
    */
    ioIPBlockRecord.setIPFrom (iIPBlockRecordValues.get<int> ("ip_from"));
    ioIPBlockRecord.setIPTo (iIPBlockRecordValues.get<int> ("ip_to"));
    ioIPBlockRecord.setRegistry (iIPBlockRecordValues.get<std::string> ("registry"));
    ioIPBlockRecord.setAssignedDate (iIPBlockRecordValues.get<int> ("assigned_date"));
    ioIPBlockRecord.setCountryCode2 (iIPBlockRecordValues.get<std::string> ("country_code_2"));
    // The city code will be set to the default value (empty string)
    // when the column is null
    ioIPBlockRecord.setCountryCode3 (iIPBlockRecordValues.get<std::string> ("country_code_3", ""));
    // The city code will be set to the default value (empty string)
    // when the column is null
    ioIPBlockRecord.setCountry (iIPBlockRecordValues.get<std::string> ("country_name", ""));
  }

  // //////////////////////////////////////////////////////////////////////
  void type_conversion<OPENGEOPP::IPBlockRecord_T>::
  to_base (const OPENGEOPP::IPBlockRecord_T& iIPBlockRecord,
           values& ioIPBlockRecordValues,
           indicator& ioIndicator) {
    const indicator lCountryCodeIndicator =
      iIPBlockRecord.getCountryCode3().empty() ? i_null : i_ok;
    const indicator lCountryNameIndicator =
      iIPBlockRecord.getCountryName().empty() ? i_null : i_ok;
    ioIPBlockRecordValues.set ("ip_from", iIPBlockRecord.getIPFrom());
    ioIPBlockRecordValues.set ("ip_to", iIPBlockRecord.getIPTo());
    ioIPBlockRecordValues.set ("registry", iIPBlockRecord.getRegistry());
    ioIPBlockRecordValues.set ("assigned_date",
                               iIPBlockRecord.getAssignedDate());
    ioIPBlockRecordValues.set ("country_code2",
                               iIPBlockRecord.getCountryCode2());
    ioIPBlockRecordValues.set ("country_code3",
                               iIPBlockRecord.getCountryCode3(),
                               lCountryCodeIndicator);
    ioIPBlockRecordValues.set ("country_name",
                               iIPBlockRecord.getCountryName(),
                               lCountryNameIndicator);
    ioIndicator = i_ok;
  }

}

namespace OPENGEOPP {

}
