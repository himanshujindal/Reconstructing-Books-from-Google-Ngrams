#include <stdio.h>
#include <string.h>

const int _ORIGIN_ = 0;
const char _DELIM_ = ' ';
const char _NEW_LINE_ = '\n';
const char _TAB_ = '\t';

int main( int argc, char *argv[] ) {
	char firstDelimFlag = 'F', lastDelimFlag = 'T', gramFile[100], tempChar;
	FILE *ipFile, *opFile;
	int delimCnt = 0, firstDelimPos, charRead;

	if( argc < 3 ) {
		printf( "Invalid no of arguments\n" );
		printf( "Usage: ./fileSplitter <file to be splitted> <no of grams required>\n" );
		return 1;
	}

	ipFile = fopen( argv[1], "r" );
	if ( NULL == ipFile ) {
		perror( "Error opening file" );
		return 1;
	}

	strcat( gramFile, argv[1] );
	strcat( gramFile, argv[2] );

	opFile = fopen( gramFile, "w" );
	if ( NULL == ipFile ) {
		perror( "Error opening file" );
		return 1;
	}

	const int gramLimit = atoi( argv[2] );

	while ( !feof( ipFile ) ){
		charRead = fgetc( ipFile );

		if ( ( _DELIM_ == charRead ) || ( _NEW_LINE_ == charRead ) || ( _TAB_ == charRead ) ) {
			tempChar = fgetc( ipFile );
			while ( ( tempChar == _NEW_LINE_ ) || ( tempChar == _DELIM_ ) || ( tempChar == _TAB_ ) ) {
				tempChar = fgetc( ipFile );
			}

			if( EOF == tempChar )
				break;

			fseek ( ipFile, ftell ( ipFile ) - 1, _ORIGIN_ );

			if( ( _NEW_LINE_ == charRead ) || ( _TAB_ == charRead ) )
				charRead = _DELIM_;

			if( _DELIM_ == charRead ) {
				if ( 'F' == firstDelimFlag ){
					firstDelimPos = ftell( ipFile );
					firstDelimFlag = 'T';
				}

				++delimCnt;

				if ( delimCnt == gramLimit ){
					fseek( ipFile, firstDelimPos, _ORIGIN_ );
					firstDelimFlag = 'F';
					charRead = _NEW_LINE_;
					delimCnt = 0;
				}
			}
		}
	
		fputc( charRead, opFile );
	}

	fclose(ipFile);
	fclose(opFile);

	return 0;
}
