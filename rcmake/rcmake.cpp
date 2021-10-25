#include<iostream>
#include<cstdio>
#include<cstring>
#include<cctype>
#include<set>
#include<string>
#include<algorithm>
using namespace std;
int iconCnt = 0;
int bmpCnt  = 0;
char *filetype;
char tagName[100],tagType[50],tagPath[50];

struct resourceInfo{
	string name;
	string path;
	string type;
	bool operator < (const resourceInfo &x)const{
		if(type != x.type){
			return type < x.type;
		}
		return name < x.name;
	}
}ri[100010]; 
int cnt = 0;

int main(int argc, char * argv[]){
	printf("resource file generator v0.0.1  dcy11011@foxmail.com\n");
	if(argc<2){
		printf("    help: rcmake [rcm filename]\n");
		printf("       convert rcs file into a rc file and an inc file\n");
		return 1;
	}
	char * filename = argv[1];
	FILE *inputFile = fopen(filename, "r");
	if(inputFile == NULL){
		printf("  [error] Failed to open input file.\n");
		return 1;
	}
	while(fscanf(inputFile, "%s %s %s",tagName,tagType,tagPath)==3){
		strupr(tagType);
		if(strcmp(tagType,"ICON")&&strcmp(tagType, "BITMAP")){
			printf(" [error] invalid resource type in line: %s %s %s", tagName, tagType, tagPath);
			return 1;
		}
		ri[cnt].name = tagName;
		ri[cnt].type = tagType;
		ri[cnt].path = tagPath;
		cnt++;
		cout<<cnt<<endl;
	}
	fclose(inputFile);
	
	filetype = strrchr(filename,'.');
	filetype[0]='\0';
	filetype++;
	if(strcmp(filetype,"rcm")){
		printf("  [error] Input file type error.\n");
		return 1;
	}
	filetype -- ;
	strcat(filetype,".rc\0");
	FILE *rcOut = fopen(filename,"w");
	filetype[0]='\0';
	strcat(filetype,".inc\0");
	FILE *incOut = fopen(filename,"w");
	
	sort(ri,ri+cnt);
	
	set<string> se;
	for(int i=0;i<cnt;i++){
		if(se.find(ri[i].name)!=se.end()){
			printf(" [error] Repeated tag name: %s",ri[i].name.c_str());
			return 1;
		}
		se.insert(ri[i].name);
	}
	
	for(int i=0;i<cnt;i++){
		fprintf(rcOut,"#define %s %d\n",ri[i].name.c_str(), i+1000);
	}
	for(int i=0;i<cnt;i++){
		fprintf(rcOut,"%s %s %s\n",ri[i].name.c_str(),ri[i].type.c_str(),ri[i].path.c_str());
	}
	for(int i=0;i<cnt;i++){
		fprintf(incOut,"%s  EQU  %d\n",ri[i].name.c_str(),i+1000);
	}
	
	fclose(rcOut);
	fclose(incOut);
	return 0;
} 
