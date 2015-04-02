

This is a parser for Hawaii Revised Statues. There are tools to download HRS, extract citations, and create records in mongo based on the information in the citation. The hope is that you could build a viewer of HRS that would actually link directly to the documents it refers to.


# install dependencies
curl -L http://cpanmin.us | perl - --sudo App::cpanminus
cpanm -i JSON
cpanm -i File::Find::Rule
cpanm -i Parse::RecDescent
cpanm -i Test::Deep

# build test data (after making changes)
cd t/
perl citations refresh
cd data
# review text* files to ensure they are correct

# run tests
cd t/
perl citations.pl

# specify URL and download hrs files to local file system
vim download_hrs.pl
perl download_hrs.pl

# define session collection
perl create_session_collection.pl > session.json
mongoimport --db law --collection session -file session.json --jsonArray

# check mongo
mongo
use law
db.session.find()

# create section collection
mongo
db.section.remove(<query>, <justOne>)
perl create_secton_collection.pl
for i in `ls json/section_*.json`; do echo $i && mongoimport --db law --collection section -file json/$i --jsonArray; done

# retreive sections
db.section.find({session:"hrs2013",chapter:"340E", section:"21"});
db.section.find({"title": /physician/i})
db.section.find({"title": /physician/i}, {title:1, _id:0})

# DON: log errors instead of dying, e.g. found one with 2 versions of the same section in the file
# also, how will we know to skip this one? perhaps need a cache listing ones we've done?
# http://kivasti.com/hrscurrent/Vol06_Ch0321-0344/HRS0329/HRS_0329-0059.htm

# TODO: create web interface 


# install search


# TODO: download acts to local filesystem
- for each section, for each citation, download acts

# TODO: create act collection
- traverse acts on local filesystem
- convert / clean / remove nav links
- escape quotes and spit out json
- mongoimport

# TODO: UI to assign blame

# TODO: script to automatically assign blame

# TODO: explore comittee reports, public testimony

# TODO: create UI to add annotations for notes and sources








