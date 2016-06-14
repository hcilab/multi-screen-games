//======================================================================================================
// Author: David Hanna
//
// Miscellaneous functions to help with miscellaneous things.
//======================================================================================================

public class JSONArrayParseResult
{
  public JSONArray jsonArray = null;
  public String remainingString = null;
}

public JSONArrayParseResult parseJSONArrayFromString(String jsonArrayString)
{
  JSONArrayParseResult parseResult = new JSONArrayParseResult();
  if (jsonArrayString.length() == 0)
  {
    return parseResult;
  }
  
  jsonArrayString = jsonArrayString.trim();
  char[] jsonArrayCharacters = jsonArrayString.toCharArray();
  
  if (jsonArrayCharacters[0] == '[')
  {
    int openBracketCount = 1;
    
    for (int i = 1; i < jsonArrayCharacters.length; i++)
    {
      if (jsonArrayCharacters[i] == '[')
      {
        openBracketCount++;
      }
      else if (jsonArrayCharacters[i] == ']')
      {
        openBracketCount--;
      }
      
      if (openBracketCount == 0)
      {
        parseResult.jsonArray = JSONArray.parse(jsonArrayString.substring(0, i + 1));
        
        if (i < jsonArrayString.length() - 1)
        {
          parseResult.remainingString = jsonArrayString.substring(i + 1, jsonArrayString.length());
        }
        else
        {
          parseResult.remainingString = "";
        }
        
        break;
      }
    }
  }
  
  return parseResult;
}