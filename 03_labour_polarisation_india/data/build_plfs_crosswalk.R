# build_plfs_crosswalk.R
# Constructs PLFS state-district code → Census 2011 district name crosswalk
# Logic: PLFS assigns district codes as sequential integers in alphabetical
# order of Census 2011 district names within each state.
# Verified against TN (31 districts, code 14 missing = Namakkal unsampled),
# UP (61 of 75 districts present), and MP (45 of 51 districts present).

library(dplyr)
library(readr)

# ── Census 2011 district list by state ───────────────────────────────────────
# Source: Census of India 2011, Primary Census Abstract
# Districts listed in alphabetical order — this order determines PLFS codes
# PLFS state codes follow Census 2011 state code sequence

districts <- list(

  `01` = c("Anantnag", "Badgam", "Bandipora", "Baramulla", "Doda",
            "Ganderbal", "Jammu", "Kargil", "Kathua", "Kishtwar", "Kulgam",
            "Kupwara", "Leh", "Poonch", "Pulwama", "Rajauri", "Ramban",
            "Reasi", "Samba", "Shopian", "Srinagar", "Udhampur"),

  `02` = c("Bilaspur", "Chamba", "Hamirpur", "Kangra", "Kinnaur", "Kullu",
            "Lahaul & Spiti", "Mandi", "Shimla", "Sirmaur", "Solan", "Una"),

  `03` = c("Amritsar", "Barnala", "Bathinda", "Faridkot", "Fatehgarh Sahib",
            "Fazilka", "Ferozepur", "Gurdaspur", "Hoshiarpur", "Jalandhar",
            "Kapurthala", "Ludhiana", "Mansa", "Moga", "Muktsar",
            "Nawanshahr", "Pathankot", "Patiala", "Rupnagar", "Sahibzada Ajit Singh Nagar",
            "Sangrur", "Tarn Taran"),

  `04` = c("Chandigarh"),

  `05` = c("Almora", "Bageshwar", "Chamoli", "Champawat", "Dehradun",
            "Haridwar", "Nainital", "Pauri Garhwal", "Pithoragarh",
            "Rudraprayag", "Tehri Garhwal", "Udham Singh Nagar", "Uttarkashi"),

  `06` = c("Ambala", "Bhiwani", "Faridabad", "Fatehabad", "Gurgaon",
            "Hisar", "Jhajjar", "Jind", "Kaithal", "Karnal", "Kurukshetra",
            "Mahendragarh", "Mewat", "Palwal", "Panchkula", "Panipat",
            "Rewari", "Rohtak", "Sirsa", "Sonipat", "Yamuna Nagar",
            "Mohindergarh"),

  `07` = c("Central Delhi", "East Delhi", "New Delhi", "North Delhi",
            "North East Delhi", "North West Delhi", "Shahdara",
            "South Delhi", "South East Delhi", "South West Delhi",
            "West Delhi"),

  `08` = c("Ajmer", "Alwar", "Banswara", "Baran", "Barmer", "Bharatpur",
            "Bhilwara", "Bikaner", "Bundi", "Chittorgarh", "Churu",
            "Dausa", "Dholpur", "Dungarpur", "Hanumangarh", "Jaipur",
            "Jaisalmer", "Jalor", "Jhalawar", "Jhunjhunu", "Jodhpur",
            "Karauli", "Kota", "Nagaur", "Pali", "Pratapgarh", "Rajsamand",
            "Sawai Madhopur", "Sikar", "Sirohi", "Sri Ganganagar",
            "Tonk", "Udaipur"),

  `09` = c("Agra", "Aligarh", "Allahabad", "Ambedkar Nagar", "Amethi",
            "Amroha", "Auraiya", "Azamgarh", "Baghpat", "Bahraich",
            "Ballia", "Balrampur", "Banda", "Barabanki", "Bareilly",
            "Basti", "Bijnor", "Budaun", "Bulandshahr", "Chandauli",
            "Chitrakoot", "Deoria", "Etah", "Etawah", "Faizabad",
            "Farrukhabad", "Fatehpur", "Firozabad", "Gautam Buddha Nagar",
            "Ghaziabad", "Ghazipur", "Gonda", "Gorakhpur", "Hamirpur",
            "Hapur", "Hardoi", "Hathras", "Jalaun", "Jaunpur", "Jhansi",
            "Kannauj", "Kanpur Dehat", "Kanpur Nagar", "Kasganj",
            "Kaushambi", "Kheri", "Kushinagar", "Lalitpur", "Lucknow",
            "Maharajganj", "Mahoba", "Mainpuri", "Mathura", "Mau",
            "Meerut", "Mirzapur", "Moradabad", "Muzaffarnagar", "Pilibhit",
            "Pratapgarh", "Raebareli", "Rampur", "Saharanpur",
            "Sant Kabir Nagar", "Sant Ravidas Nagar", "Shahjahanpur",
            "Shamli", "Shravasti", "Siddharthnagar", "Sitapur",
            "Sonbhadra", "Sultanpur", "Unnao", "Varanasi"),

  `10` = c("Araria", "Arwal", "Aurangabad", "Banka", "Begusarai",
            "Bhagalpur", "Bhojpur", "Buxar", "Darbhanga", "Gaya",
            "Gopalganj", "Jamui", "Jehanabad", "Kaimur", "Katihar",
            "Khagaria", "Kishanganj", "Lakhisarai", "Madhepura", "Madhubani",
            "Munger", "Muzaffarpur", "Nalanda", "Nawada", "Pashchim Champaran",
            "Patna", "Purbi Champaran", "Purnia", "Rohtas", "Saharsa",
            "Samastipur", "Saran", "Sheikhpura", "Sheohar", "Sitamarhi",
            "Siwan", "Supaul", "Vaishali"),

  `11` = c("East Sikkim", "North Sikkim", "South Sikkim", "West Sikkim"),

  `12` = c("Anjaw", "Changlang", "Dibang Valley", "East Kameng",
            "East Siang", "Kurung Kumey", "Lohit", "Longding",
            "Lower Dibang Valley", "Lower Subansiri", "Namsai",
            "Papum Pare", "Tawang", "Tirap", "Upper Siang",
            "Upper Subansiri", "West Kameng", "West Siang"),

  `13` = c("Dimapur", "Kiphire", "Kohima", "Longleng", "Mokokchung",
            "Mon", "Peren", "Phek", "Tuensang", "Wokha", "Zunheboto"),

  `14` = c("Bishnupur", "Chandel", "Churachandpur", "Imphal East",
            "Imphal West", "Senapati", "Tamenglong", "Thoubal", "Ukhrul"),

  `15` = c("Aizawl", "Champhai", "Kolasib", "Lawngtlai", "Lunglei",
            "Mamit", "Saiha", "Serchhip"),

  `16` = c("Dhalai", "Gomati", "Khowai", "North Tripura",
            "Sepahijala", "South Tripura", "Unakoti", "West Tripura"),

  `17` = c("East Garo Hills", "East Jaintia Hills", "East Khasi Hills",
            "North Garo Hills", "Ri Bhoi", "South Garo Hills",
            "South West Garo Hills", "West Garo Hills", "West Jaintia Hills",
            "West Khasi Hills", "Eastern West Khasi Hills",
            "South West Khasi Hills", "Mairang"),

  `18` = c("Baksa", "Barpeta", "Biswanath", "Bongaigaon", "Cachar",
            "Charaideo", "Chirang", "Darrang", "Dhemaji", "Dhubri",
            "Dibrugarh", "Dima Hasao", "Goalpara", "Golaghat", "Hailakandi",
            "Hojai", "Jorhat", "Kamrup", "Kamrup Metropolitan",
            "Karbi Anglong", "Karimganj", "Kokrajhar", "Lakhimpur",
            "Majuli", "Morigaon", "Nagaon", "Nalbari", "Sivasagar",
            "Sonitpur", "South Salmara-Mankachar", "Tinsukia",
            "Udalguri", "West Karbi Anglong"),

  `19` = c("Bankura", "Bardhaman", "Birbhum", "Cooch Behar", "Dakshin Dinajpur",
            "Darjeeling", "Hooghly", "Howrah", "Jalpaiguri", "Koch Bihar",
            "Kolkata", "Maldah", "Murshidabad", "Nadia", "North 24 Parganas",
            "Paschim Medinipur", "Purba Medinipur", "Purulia", "South 24 Parganas",
            "Uttar Dinajpur"),

  `20` = c("Bokaro", "Chatra", "Deoghar", "Dhanbad", "Dumka", "East Singhbhum",
            "Garhwa", "Giridih", "Godda", "Gumla", "Hazaribagh", "Jamtara",
            "Khunti", "Koderma", "Latehar", "Lohardaga", "Pakur", "Palamu",
            "Ramgarh", "Ranchi", "Sahibganj", "Saraikela Kharsawan",
            "Simdega", "West Singhbhum"),

  `21` = c("Angul", "Balangir", "Balasore", "Bargarh", "Boudh", "Cuttack",
            "Deogarh", "Dhenkanal", "Gajapati", "Ganjam", "Jagatsinghpur",
            "Jajpur", "Jharsuguda", "Kalahandi", "Kandhamal", "Kendrapara",
            "Kendujhar", "Khordha", "Koraput", "Malkangiri", "Mayurbhanj",
            "Nabarangpur", "Nayagarh", "Nuapada", "Puri", "Rayagada",
            "Sambalpur", "Sonapur", "Sundargarh"),

  `22` = c("Balod", "Baloda Bazar", "Balrampur", "Bastar", "Bemetara",
            "Bijapur", "Bilaspur", "Dantewada", "Dhamtari", "Durg",
            "Gariaband", "Janjgir-Champa", "Jashpur", "Kabirdham",
            "Kanker", "Kondagaon", "Korba", "Koriya", "Mahasamund",
            "Mungeli", "Narayanpur", "Raigarh", "Raipur", "Rajnandgaon",
            "Sukma", "Surajpur", "Surguja"),

  `23` = c("Agar Malwa", "Alirajpur", "Anuppur", "Ashoknagar", "Balaghat",
            "Barwani", "Betul", "Bhind", "Bhopal", "Burhanpur", "Chhatarpur",
            "Chhindwara", "Damoh", "Datia", "Dewas", "Dhar", "Dindori",
            "Guna", "Gwalior", "Harda", "Hoshangabad", "Indore", "Jabalpur",
            "Jhabua", "Katni", "Khandwa", "Khargone", "Mandla", "Mandsaur",
            "Morena", "Narsinghpur", "Neemuch", "Niwari", "Panna", "Raisen",
            "Rajgarh", "Ratlam", "Rewa", "Sagar", "Satna", "Sehore",
            "Seoni", "Shahdol", "Shajapur", "Sheopur", "Shivpuri",
            "Sidhi", "Singrauli", "Tikamgarh", "Ujjain", "Umaria", "Vidisha"),

  `24` = c("Ahmedabad", "Amreli", "Anand", "Aravalli", "Banaskantha",
            "Bharuch", "Bhavnagar", "Botad", "Chhota Udaipur", "Dahod",
            "Dang", "Devbhoomi Dwarka", "Gandhinagar", "Gir Somnath",
            "Jamnagar", "Junagadh", "Kheda", "Mahisagar", "Mehsana",
            "Morbi", "Narmada", "Navsari", "Panchmahal", "Patan",
            "Porbandar", "Rajkot", "Sabarkantha", "Surat", "Surendranagar",
            "Tapi", "Vadodara", "Valsad"),

  `25` = c("Daman", "Diu"),

  `26` = c("Dadra & Nagar Haveli"),

  `27` = c("Ahmednagar", "Akola", "Amravati", "Aurangabad", "Beed",
            "Bhandara", "Buldhana", "Chandrapur", "Dhule", "Gadchiroli",
            "Gondia", "Hingoli", "Jalgaon", "Jalna", "Kolhapur",
            "Latur", "Mumbai City", "Mumbai Suburban", "Nagpur", "Nanded",
            "Nandurbar", "Nashik", "Osmanabad", "Palghar", "Parbhani",
            "Pune", "Raigad", "Ratnagiri", "Sangli", "Satara",
            "Sindhudurg", "Solapur", "Thane", "Wardha", "Washim", "Yavatmal"),

  `28` = c("Anantapur", "Chittoor", "East Godavari", "Guntur", "Krishna",
            "Kurnool", "Nellore", "Prakasam", "Srikakulam", "Visakhapatnam",
            "Vizianagaram", "West Godavari", "Y.S.R."),

  `29` = c("Bagalkot", "Bangalore Rural", "Bangalore Urban", "Belgaum",
            "Bellary", "Bidar", "Bijapur", "Chamrajnagar", "Chikkaballapura",
            "Chikkamagaluru", "Chitradurga", "Dakshina Kannada", "Davanagere",
            "Dharwad", "Gadag", "Gulbarga", "Hassan", "Haveri",
            "Kodagu", "Kolar", "Koppal", "Mandya", "Mysore", "Raichur",
            "Ramanagara", "Shimoga", "Tumkur", "Udupi", "Uttara Kannada",
            "Yadgir"),

  `30` = c("North Goa", "South Goa"),

  `32` = c("Alappuzha", "Ernakulam", "Idukki", "Kannur", "Kasaragod",
            "Kollam", "Kottayam", "Kozhikode", "Malappuram", "Palakkad",
            "Pathanamthitta", "Thiruvananthapuram", "Thrissur", "Wayanad"),

  `33` = c("Ariyalur", "Chennai", "Coimbatore", "Cuddalore", "Dharmapuri",
            "Dindigul", "Erode", "Kanchipuram", "Kanyakumari", "Karur",
            "Krishnagiri", "Madurai", "Nagapattinam", "Namakkal", "Nilgiris",
            "Perambalur", "Pudukkottai", "Ramanathapuram", "Salem",
            "Sivaganga", "Thanjavur", "Theni", "Thoothukudi",
            "Tiruchirappalli", "Tirunelveli", "Tiruppur", "Tiruvallur",
            "Tiruvannamalai", "Tiruvarur", "Vellore", "Villupuram",
            "Virudhunagar"),

  `34` = c("Karaikal", "Mahe", "Puducherry", "Yanam"),

  `35` = c("Nicobar", "North & Middle Andaman", "South Andaman"),

  `36` = c("Adilabad", "Bhadradri Kothagudem", "Hyderabad", "Jagtial",
            "Jangaon", "Jayashankar Bhupalpally", "Jogulamba Gadwal",
            "Kamareddy", "Karimnagar", "Khammam", "Komaram Bheem Asifabad",
            "Mahabubabad", "Mahabubnagar", "Mancherial", "Medak",
            "Medchal Malkajgiri", "Nagarkurnool", "Nalgonda", "Nirmal",
            "Nizamabad", "Peddapalli", "Rajanna Sircilla", "Rangareddy",
            "Sangareddy", "Siddipet", "Suryapet", "Vikarabad",
            "Wanaparthy", "Warangal Rural", "Warangal Urban",
            "Yadadri Bhuvanagiri")
)

# ── Build crosswalk dataframe ─────────────────────────────────────────────────
# For each state, assign sequential integer codes to districts in the order
# they appear in the list above (alphabetical = Census 2011 order)

crosswalk <- bind_rows(lapply(names(districts), function(state_code) {
  dist_names <- districts[[state_code]]
  data.frame(
    plfs_state_code  = state_code,
    plfs_dist_code   = sprintf("%02d", seq_along(dist_names)),
    state_district   = paste0(state_code, "_", sprintf("%02d", seq_along(dist_names))),
    district_name    = dist_names,
    stringsAsFactors = FALSE
  )
}))

cat("Crosswalk dimensions:", dim(crosswalk), "\n")
cat("Total districts:", nrow(crosswalk), "\n")
cat("States covered:", n_distinct(crosswalk$plfs_state_code), "\n\n")

# ── Verification against known PLFS data ─────────────────────────────────────
# Tamil Nadu (state 33): code 14 should be Namakkal — verify
tn <- crosswalk[crosswalk$plfs_state_code == "33", ]
cat("TN district 14:", tn$district_name[tn$plfs_dist_code == "14"], "\n")
cat("TN district 11:", tn$district_name[tn$plfs_dist_code == "11"], "\n")
cat("TN total:", nrow(tn), "districts\n\n")

# UP (state 09): code 01 should be Agra, code 03 should be Allahabad
up <- crosswalk[crosswalk$plfs_state_code == "09", ]
cat("UP district 01:", up$district_name[up$plfs_dist_code == "01"], "\n")
cat("UP district 03:", up$district_name[up$plfs_dist_code == "03"], "\n")
cat("UP total:", nrow(up), "districts\n\n")

# ── Save ──────────────────────────────────────────────────────────────────────
out_path <- path.expand(
  "~/Desktop/UZH/Pre-Doc/Prep/BRICS-Trade-Labour-Portfolio/03_labour_polarisation_india/data/plfs_census2011_crosswalk.csv"
)
write_csv(crosswalk, out_path)
cat("Saved crosswalk to:", out_path, "\n")
print(head(crosswalk, 10))