//
//  SelectTimeZoneVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 10/01/2022.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class SelectTimeZoneVC: UIViewController {
    var delegate:didSelectTimeZoneDelegate?
   
    let data = ["(GMT-11:00) Midway Island":"Pacific/Midway",
             "(GMT-11:00) Samoa" :"US/Samoa",
              "(GMT-10:00) Hawaii":"US/Hawaii",
             "(GMT-09:00) Alaska": "US/Alaska",
              "(GMT-08:00) Pacific Time (US &amp; Canada)":"US/Pacific",
             "(GMT-08:00) Tijuana": "America/Tijuana",
              "(GMT-07:00) Arizona":"US/Arizona",
              "(GMT-07:00) Mountain Time (US &amp; Canada)":"US/Mountain",
              "(GMT-07:00) Chihuahua":"America/Chihuahua",
              "(GMT-07:00) Mazatlan":"America/Mazatlan",
             "(GMT-06:00) Mexico City": "America/Mexico_City",
             "(GMT-06:00) Monterrey": "America/Monterrey",
              "(GMT-06:00) Saskatchewan":"Canada/Saskatchewan",
             "(GMT-06:00) Central Time (US &amp; Canada)": "US/Central",
              "(GMT-05:00) Eastern Time (US &amp; Canada)":"US/Eastern",
             "(GMT-05:00) Indiana (East)": "US/East-Indiana",
              "(GMT-05:00) Bogota":"America/Bogota",
              "(GMT-05:00) Lima":"America/Lima",
              "(GMT-04:30) Caracas":"America/Caracas",
             "(GMT-04:00) Atlantic Time (Canada)": "Canada/Atlantic",
             "(GMT-04:00) La Paz": "America/La_Paz",
              "(GMT-04:00) Santiago":"America/Santiago",
              "(GMT-03:30) Newfoundland":"Canada/Newfoundland",
              "(GMT-03:00) Buenos Aires":"America/Buenos_Aires",
              "(GMT-03:00) Greenland":"Greenland",
              "(GMT-02:00) Stanley":"Atlantic/Stanley",
              "(GMT-01:00) Azores":"Atlantic/Azores",
              "(GMT-01:00) Cape Verde Is.":"Atlantic/Cape_Verde",
             "(GMT) Casablanca": "Africa/Casablanca",
             "(GMT) Dublin": "Europe/Dublin",
              "(GMT) Lisbon":"Europe/Lisbon",
              "(GMT) London":"Europe/London",
              "(GMT) Monrovia":"Africa/Monrovia",
             "(GMT+01:00) Amsterdam": "Europe/Amsterdam",
              "(GMT+01:00) Belgrade":"Europe/Belgrade",
              "(GMT+01:00) Berlin":"Europe/Berlin",
              "(GMT+01:00) Bratislava":"Europe/Bratislava",
              "(GMT+01:00) Brussels":"Europe/Brussels",
              "(GMT+01:00) Budapest":"Europe/Budapest",
              "(GMT+01:00) Copenhagen":"Europe/Copenhagen",
              "(GMT+01:00) Ljubljana":"Europe/Ljubljana",
              "(GMT+01:00) Madrid":"Europe/Madrid",
              "(GMT+01:00) Paris":"Europe/Paris",
             "(GMT+01:00) Prague": "Europe/Prague",
              "(GMT+01:00) Rome":"Europe/Rome",
              "(GMT+01:00) Sarajevo":"Europe/Sarajevo",
              "(GMT+01:00) Skopje":"Europe/Skopje",
              "(GMT+01:00) Stockholm":"Europe/Stockholm",
              "(GMT+01:00) Vienna":"Europe/Vienna",
             "(GMT+01:00) Warsaw": "Europe/Warsaw",
              "(GMT+01:00) Zagreb":"Europe/Zagreb",
              "(GMT+02:00) Athens":"Europe/Athens",
              "(GMT+02:00) Bucharest":"Europe/Bucharest",
              "(GMT+02:00) Cairo":"Africa/Cairo",
              "(GMT+02:00) Harare":"Africa/Harare",
             "(GMT+02:00) Helsinki": "Europe/Helsinki",
             "(GMT+02:00) Istanbul": "Europe/Istanbul",
              "(GMT+02:00) Jerusalem":"Asia/Jerusalem",
              "(GMT+02:00) Kyiv":"Europe/Kiev",
              "(GMT+02:00) Minsk":"Europe/Minsk",
              "(GMT+02:00) Riga":"Europe/Riga",
              "(GMT+02:00) Sofia":"Europe/Sofia",
              "(GMT+02:00) Tallinn":"Europe/Tallinn",
             "(GMT+02:00) Vilnius": "Europe/Vilnius",
             "(GMT+03:00) Baghdad":"Asia/Baghdad",
              "(GMT+03:00) Kuwait":"Asia/Kuwait",
             "(GMT+03:00) Nairobi": "Africa/Nairobi",
              "(GMT+03:00) Riyadh":"Asia/Riyadh",
              "(GMT+03:00) Moscow":"Europe/Moscow",
              "(GMT+03:30) Tehran":"Asia/Tehran",
              "(GMT+04:00) Baku":"Asia/Baku",
              "(GMT+04:00) Volgograd":"Europe/Volgograd",
              "(GMT+04:00) Muscat":"Asia/Muscat",
              "(GMT+04:00) Tbilisi":"Asia/Tbilisi",
              "(GMT+04:00) Yerevan":"Asia/Yerevan",
              "(GMT+04:30) Kabul":"Asia/Kabul",
              "(GMT+05:00) Karachi":"Asia/Karachi",
              "(GMT+05:00) Tashkent":"Asia/Tashkent",
              "(GMT+05:30) Kolkata":"Asia/Kolkata",
              "(GMT+05:45) Kathmandu":"Asia/Kathmandu",
              "(GMT+06:00) Ekaterinburg":"Asia/Yekaterinburg",
              "(GMT+06:00) Almaty":"Asia/Almaty",
              "(GMT+06:00) Dhaka":"Asia/Dhaka",
              "(GMT+07:00) Novosibirsk":"Asia/Novosibirsk",
              "(GMT+07:00) Bangkok":"Asia/Bangkok",
              "(GMT+07:00) Jakarta":"Asia/Jakarta",
              "(GMT+08:00) Krasnoyarsk":"Asia/Krasnoyarsk",
              "(GMT+08:00) Chongqing":"Asia/Chongqing",
              "(GMT+08:00) Hong Kong":"Asia/Hong_Kong",
              "(GMT+08:00) Kuala Lumpur":"Asia/Kuala_Lumpur",
              "(GMT+08:00) Perth":"Australia/Perth",
             "(GMT+08:00) Singapore": "Asia/Singapore",
             "(GMT+08:00) Taipei": "Asia/Taipei",
              "(GMT+08:00) Ulaan Bataar":"Asia/Ulaanbaatar",
              "(GMT+08:00) Urumqi":"Asia/Urumqi",
              "(GMT+09:00) Irkutsk":"Asia/Irkutsk",
              "(GMT+09:00) Seoul":"Asia/Seoul",
             "(GMT+09:00) Tokyo": "Asia/Tokyo",
              "(GMT+09:30) Adelaide":"Australia/Adelaide",
              "(GMT+09:30) Darwin":"Australia/Darwin",
              "(GMT+10:00) Yakutsk":"Asia/Yakutsk",
              "(GMT+10:00) Brisbane":"Australia/Brisbane",
              "(GMT+10:00) Canberra":"Australia/Canberra",
              "(GMT+10:00) Guam":"Pacific/Guam",
              "(GMT+10:00) Hobart":"Australia/Hobart",
              "(GMT+10:00) Melbourne":"Australia/Melbourne",
             "(GMT+10:00) Port Moresby": "Pacific/Port_Moresby",
             "(GMT+10:00) Sydney": "Australia/Sydney",
              "(GMT+11:00) Vladivostok":"Asia/Vladivostok",
            "(GMT+12:00) Magadan":  "Asia/Magadan",
             "(GMT+12:00) Auckland": "Pacific/Auckland",
              "(GMT+12:00) Fiji":"Pacific/Fiji"]
    
    let data1 = ["(GMT-11:00) Midway Island",
           "(GMT-11:00) Samoa",
          "(GMT-10:00) Hawaii",
         "(GMT-09:00) Alaska",
          "(GMT-08:00) Pacific Time (US &amp; Canada)",
           "(GMT-08:00) Tijuana",
          "(GMT-07:00) Arizona",
           "(GMT-07:00) Mountain Time (US &amp; Canada)",
           "(GMT-07:00) Chihuahua",
          "(GMT-07:00) Mazatlan",
           "(GMT-06:00) Mexico City",
           "(GMT-06:00) Monterrey",
          "(GMT-06:00) Saskatchewan",
           "(GMT-06:00) Central Time (US &amp; Canada)",
           "(GMT-05:00) Eastern Time (US &amp; Canada)",
          "(GMT-05:00) Indiana (East)",
          "(GMT-05:00) Bogota",
           "(GMT-05:00) Lima",
           "(GMT-04:30) Caracas",
           "(GMT-04:00) Atlantic Time (Canada)",
           "(GMT-04:00) La Paz",
           "(GMT-04:00) Santiago",
           "(GMT-03:30) Newfoundland",
           "(GMT-03:00) Buenos Aires",
          "(GMT-03:00) Greenland",
           "(GMT-02:00) Stanley",
           "(GMT-01:00) Azores",
          "(GMT-01:00) Cape Verde Is.",
          "(GMT) Casablanca",
          "(GMT) Dublin",
           "(GMT) Lisbon",
          "(GMT) London",
          "(GMT) Monrovia",
           "(GMT+01:00) Amsterdam",
           "(GMT+01:00) Belgrade",
           "(GMT+01:00) Berlin",
           "(GMT+01:00) Bratislava",
           "(GMT+01:00) Brussels",
           "(GMT+01:00) Budapest",
           "(GMT+01:00) Copenhagen",
           "(GMT+01:00) Ljubljana",
           "(GMT+01:00) Madrid",
           "(GMT+01:00) Paris",
           "(GMT+01:00) Prague",
           "(GMT+01:00) Rome",
           "(GMT+01:00) Sarajevo",
          "(GMT+01:00) Skopje",
           "(GMT+01:00) Stockholm",
           "(GMT+01:00) Vienna",
           "(GMT+01:00) Warsaw",
           "(GMT+01:00) Zagreb",
           "(GMT+02:00) Athens",
           "(GMT+02:00) Bucharest",
           "(GMT+02:00) Cairo",
           "(GMT+02:00) Harare",
           "(GMT+02:00) Helsinki",
           "(GMT+02:00) Istanbul",
          "(GMT+02:00) Jerusalem",
           "(GMT+02:00) Kyiv",
           "(GMT+02:00) Minsk",
          "(GMT+02:00) Riga",
           "(GMT+02:00) Sofia",
          "(GMT+02:00) Tallinn",
           "(GMT+02:00) Vilnius",
           "(GMT+03:00) Baghdad",
          "(GMT+03:00) Kuwait",
           "(GMT+03:00) Nairobi",
           "(GMT+03:00) Riyadh",
           "(GMT+03:00) Moscow",
           "(GMT+03:30) Tehran",
           "(GMT+04:00) Baku",
           "(GMT+04:00) Volgograd",
           "(GMT+04:00) Muscat",
           "(GMT+04:00) Tbilisi",
          "(GMT+04:00) Yerevan",
           "(GMT+04:30) Kabul",
           "(GMT+05:00) Karachi",
           "(GMT+05:00) Tashkent",
           "(GMT+05:30) Kolkata",
           "(GMT+05:45) Kathmandu",
           "(GMT+06:00) Ekaterinburg",
          "(GMT+06:00) Almaty",
           "(GMT+06:00) Dhaka",
           "(GMT+07:00) Novosibirsk",
          "(GMT+07:00) Bangkok",
           "(GMT+07:00) Jakarta",
           "(GMT+08:00) Krasnoyarsk",
           "(GMT+08:00) Chongqing",
           "(GMT+08:00) Hong Kong",
          "(GMT+08:00) Kuala Lumpur",
           "(GMT+08:00) Perth",
           "(GMT+08:00) Singapore",
           "(GMT+08:00) Taipei",
         "(GMT+08:00) Ulaan Bataar",
          "(GMT+08:00) Urumqi",
           "(GMT+09:00) Irkutsk",
          "(GMT+09:00) Seoul",
           "(GMT+09:00) Tokyo",
           "(GMT+09:30) Adelaide",
           "(GMT+09:30) Darwin",
       "(GMT+10:00) Yakutsk",
        "(GMT+10:00) Brisbane",
           "(GMT+10:00) Canberra",
           "(GMT+10:00) Guam",
           "(GMT+10:00) Hobart",
          "(GMT+10:00) Melbourne",
           "(GMT+10:00) Port Moresby",
         "(GMT+10:00) Sydney",
           "(GMT+11:00) Vladivostok",
           "(GMT+12:00) Magadan",
           "(GMT+12:00) Auckland",
           "(GMT+12:00) Fiji"]

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension SelectTimeZoneVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? UITableViewCell
        cell?.textLabel?.text = self.data1[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.delegate?.didSelectTimeZone(timeZone: self.data[self.data1[indexPath.row]]!, name: self.data1[indexPath.row], index: indexPath.row)
        }
    }
}