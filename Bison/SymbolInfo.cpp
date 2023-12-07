#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cstdio>
#include<fstream>
#include<vector>
using namespace std;

class  SymbolInfo
{
private:
    SymbolInfo *next;
    string name;
    string type;
    int arr;
    string returnType;
    int numberOfparameters;
    vector<string> parameterList;
    string variableType;
public:
    SymbolInfo(string name,string type)
    {
        arr = 0;
        numberOfparameters = 0;
        returnType="" ;
        variableType="";
        next=nullptr;
        this->name=name;
        this->type=type;
    }
    void setNext(SymbolInfo *objpo)
    {
        //SymbolInfo *objP;
        next=objpo;
    }
    void setType(string typ)
    {
        string type;
        type=typ;
    }
    string getName()
    {
        return name;
    }
    string getType()
    {
        return type;
    }
    SymbolInfo* getNext()
    {
        return next;
    }
    void setArr(int a)
    {
        arr=a;
    }
    int getArr()
    {
        return arr;
    }
    void setVariableType(string sv)
    {
        variableType=sv;
    }
    string getVariableType()
    {
        return variableType;
    }

    void setrTpLnP(int np,string rT,vector<string> pL)
    {

        numberOfparameters=np;
        returnType=rT;
        for(int i=0; i<np ;i++)
        {
            parameterList.push_back(pL[i]);
        }
    }
    vector<string>getParameterList()
    {
        return parameterList;
    }
    string getReturnType()
    {
        return returnType;
    }
    int getNumberOfparameters()
    {
        return numberOfparameters;
    }
};
