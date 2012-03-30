#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include "stdint.h" /* Replace with <stdint.h> if appropriate */
#include <cstring>
#include "hash_32a.c"

using namespace std;

const int _ASCII_CHAR_SET_CNT_ = 128;
const int _DELIM_INT_ = ' ';
const string _DELIM_STR_ = " ";
const string _NULL_STR_ = "";

struct nGram
{
	string str;
	int occ;
	unsigned int hash2;
};

struct position
{
	int pos;
	position* next;
};

struct hashmap
{
	position* data;
};

vector<hashmap> Hash;
int NGRAM;

int create_vector(vector<nGram>&, string File);
string find_suffix(string, int);
void InitializeHash();
void InsertHash(unsigned int, int);
string find_prefix(string, int);
int Get_pos(vector <nGram>&, int);
string str_end(string, int);

int main( int argc, char* argv[] )
{
	if( argc != 3 ) {
		cout << "Invalid no of arguments" << endl;
		return 1;
	}

	string ipFileName = argv[1];
	NGRAM = atoi( argv[2] );

	vector <nGram> grams;
	Hash.resize( FNV_32_PRIME );
	bool flag = false;

	InitializeHash();

	int n = create_vector( grams, ipFileName );

	for( int i = 0 ; i < n ; )
	{
		try {
			if(grams[i].occ>0)
			{
				int pos = Get_pos(grams, i);

				if(pos>=0)
				{
					if(pos==i)
					{
						i++;
					}
					else
					{				
						string app_str = str_end(grams[pos].str, NGRAM-1);

						grams[i].str.append(_DELIM_STR_);
						grams[i].str.append(app_str);
						grams[i].hash2 = grams[pos].hash2;

						if( 0 == --grams[pos].occ ) {
							( grams[pos].str ).erase( ( grams[pos].str ).begin(), ( grams[pos].str ).end() );
							grams[pos].str.swap(grams[pos].str);
						}	
					}
				}
				else
					i++;
			}
			else
				i++;
		} catch( ... ) {
			cout << "Some exception occured for i=" << i << endl;
		}
	}

	Hash.erase( Hash.begin(), Hash.end() );
	Hash.swap(Hash);

	ofstream myfile;
	ipFileName += ".recn";
	myfile.open ( ipFileName.c_str() );

	for(int i = 0; i<n; i++)
		if(grams[i].occ>0)
			myfile<<grams[i].str<<endl << flush;

	myfile.close();
	cout << "Reconstruction completed successfully for " << NGRAM <<"Grams in time:";
	
	return 0;
}

void InitializeHash()
{
	for(int i = 0; i<FNV_32_PRIME; i++)
	{
		Hash[i].data = NULL;
	}
}

int create_vector(vector <nGram> &grams, string File)
{
	ifstream file (File.c_str());
	int i = 0;
	int x = 0;

	if(file.is_open())
	{
		while ( file.good() ) 
		{
			string curLine;
			nGram curGram;
			getline(file, curLine);

			if ( curLine == _NULL_STR_ )
				break;
			else
			{
				string curString, curNum, curSuffix, curPrefix;
				int curPos = curLine.find_last_of ( _DELIM_STR_ );
				curString = curLine.substr( 0, curPos );
				curNum = curLine.substr( curPos + 1, curLine.length() - curPos );
				
				curGram.occ = atoi ( curNum.data() );
				curGram.str = curString;
				curSuffix = find_suffix( curString, NGRAM - 1 );
				x = fnv_32a_str( (char*)curSuffix.c_str(), 0 );
				curGram.hash2 = x % FNV_32_PRIME;
				curPrefix = find_prefix( curGram.str, NGRAM - 1 );
				x = fnv_32a_str( (char*)curPrefix.c_str(), 0 );
				int hash1 = x % FNV_32_PRIME;
				InsertHash( hash1, i );
				grams.push_back( curGram );
				i++;
			}
		}
	}

	return i;
}

int Get_pos(vector <nGram> &gram, int i)
{
	position *ptr = Hash[gram[i].hash2].data;
	int pos1 = -1;

	while(ptr!=NULL)
	{
		int pos = ptr->pos;
		string a, b;

		a = find_suffix(gram[i].str, NGRAM-1);
		b = find_prefix(gram[pos].str, NGRAM-1);

		if(strcmp(a.c_str(),b.c_str())==0)
		{
			if(gram[pos].occ>0)
			{
				if(pos1==-1)
				{
					pos1 = pos;
                		}
                		else
					return -1;
			}
		}

		ptr = ptr->next;
	}

	return pos1;
}

void InsertHash(unsigned int hash, int index)
{
	if(Hash[hash].data == NULL)
	{
		position * ppos = new position;
		ppos->pos = index;
		ppos->next = NULL;
		Hash[hash].data = ppos;
	}
	else
	{
		position * ppos = Hash[hash].data;

		while(ppos->next!=NULL)
		{
			ppos = ppos->next;
		}

		position * temp_pos = new position;
		temp_pos->pos = index;
		temp_pos->next = NULL;
		ppos->next = temp_pos;
	}
}

string find_suffix(string str, int a)
{
	int pos = str.length();

	while((a--)>0)
	{
		pos = str.find_last_of(_DELIM_STR_, pos - 1);
	}

	return str.substr(pos+1, str.length()-1);
}

string find_prefix(string str, int a)
{
	int pos = 0;

	while((a--)>0)
	{
		pos = str.find_first_of(_DELIM_STR_, pos+1);
	}

	return str.substr(0, pos);
}

string str_end( string str, int i)
{
	int pos = 0;

	while((i--)>0)
	{
		pos = str.find_first_of(_DELIM_STR_, pos+1);
	}

	return str.substr(pos+1, str.length()-1);
}
