echo "labels={"
cat HarvardOxford-Cortical-Lateralized.xml |grep label|cut -d\> -f2|cut -d\<  -f1|sed "s/'/''/g"|sed "s/^/'/g"|sed "s/$/'/g"

cat HarvardOxford-Subcortical.xml |grep label|cut -d\> -f2|cut -d\<  -f1|sed "s/'/''/g"|sed "s/^/'/g"|sed "s/$/'/g"

cat ../Cerebellum/Cerebellum_MNIfnirt.xml  |grep label|cut -d\> -f2|cut -d\<  -f1|sed "s/'/''/g"|sed "s/^/'/g"|sed "s/$/'/g"
echo "};"
