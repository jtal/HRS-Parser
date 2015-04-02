

This is a parser for Hawaii Revised Statues. There are tools to download HRS, extract citations, and create records in mongo based on the information in the citation. The hope is that you could build a viewer of HRS that would actually link directly to the documents it refers to.

The grammar is in lib/Citations.pm


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

