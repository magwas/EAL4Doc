#!/usr/bin/env python
# coding=utf-8
import sys
import re

from sql2doxygen import SqlConverter

re1 = re.compile("^[ 	]*\[([^,]*).*\]")
re2 = [
 [re.compile("\[PrincipalPermission\(([^,]*),(.*)\)(.*)\]"),
  r"[PrincipalPermission(\1,\2)\3] /// @permission{\1,\2} @tsf{CMS jogosultságkezelés} @sfr{FDP_ACF.1(cms)}\\xmlonly <audit>FailedLogin</audit><authorisation>\\endxmlonly Hozzáférésvezérlést végez. A felhasználót, annak szerepköreit és sikertelen hozzáféréseket naplózza.<br/>\\xmlonly</authorisation>\\endxmlonly"],
 [re.compile("GameHelper.Init\((.*?),(.*).$"),
  r"GameHelper.Init(\1,\2 /// @sfr{FDP_ACF.1(terminal)} @tsf{terminál authentikáció} \\xmlonly<authorisation>\\endxmlonly Hozzáférésvezérlést végez. A felhasználót(terminált), és a sikertelen hozzáféréseket naplózza.<br/> \\xmlonly</authorisation><permission>Terminál</permission>\\endxmlonly"],
 [re.compile("\[RequiresAuthentication\]"),
  r"[RequiresAuthentication] /// @sfr{FIA_UAU.2} \\xmlonly <requiresauth> \\endxmlonly @sfr{FIA_UAU.2} Használatához authentikáció szükséges <br/> \\xmlonly </requiresauth> \\endxmlonly"],
 [re.compile("\[ValidateAntiForgeryToken\]"),
  r"[ValidateAntiForgeryToken] /// \\xmlonly <antiforgery> \\endxmlonly CSRF védelemmel ellátva <br/> \\xmlonly </antiforgery> \\endxmlonly "],
 [re.compile("\[AcceptVerbs\((.*)\)(.*)\]"),
  r"[AcceptVerbs(\1)\2] /// \\xmlonly <redundant> \\endxmlonly A következő HTTP metódussal hívható: \\xmlonly <acceptverbs> \\endxmlonly \1 \\xmlonly </acceptverbs> \\endxmlonly <br/> \\xmlonly </redundant> \\endxmlonly"],
 [re.compile("\[ValidateInput(true)\]"),
  r"[ValidateInput(true)] ///  \\xmlonly <msvcinputvalidation> \\endxmlonly As MSVC beépített input validációját is alkalmazza.<br/> \\xmlonly </msvcinputvalidation> \\endxmlonly "],
 [re.compile("\[WebMethod\((.*)\)(.*)\]"),
  r"[WebMethod(\1)\2] ///  \\xmlonly <redundant> \\endxmlonly Web metódus\\xmlonly <webmethod> \\endxmlonly \1 \\xmlonly </webmethod> \\endxmlonly <br/> \\xmlonly </redundant> \\endxmlonly"],
 [re.compile("\[WebService\((.*)\)(.*)\]"),
  r"[WebService(\1)\2] ///  \\xmlonly <redundant> \\endxmlonly Web Szolgáltatás(\\xmlonly <webservice> \\endxmlonly \1 \\xmlonly </webservice> \\endxmlonly) <br/> \\xmlonly </redundant> \\endxmlonly"],
 [re.compile("\[WebServiceBinding\((.*)\)(.*)\]"),
  r"[WebServiceBinding(\1)\2] /// \\xmlonly <redundant> \\endxmlonly  Web Szolgáltatás Kötése:(\\xmlonly <webservice> \\endxmlonly \1 \\xmlonly </webservice> \\endxmlonly) <br/> \\xmlonly </redundant> \\endxmlonly"],
 [re.compile("\[NoCache\]"),
  r"[NoCache] /// \\xmlonly <nocache> \\endxmlonly nem cache-elhető <br/> \\xmlonly </nocache> \\endxmlonly"],
 [re.compile("\[HttpGet\]"),
  r"[HttpGet] /// \\xmlonly <httpget> \\endxmlonly GET metódussal hívható <br/> \\xmlonly </httpget>\\endxmlonly"],
 [re.compile("\[Authorize\]"),
  r"[Authorize] /// \\xmlonly <authorize> \\endxmlonly minden bejelentkezett felhasználó használhatja <br/> \\xmlonly </authorize> \\endxmlonly"],
 [re.compile("\[NonAuthorized\((.*)\)(.*)\]"),
  r"[NonAuthorized(\1)\2] /// \\xmlonly <redundant> \\endxmlonly Nem használhatja: \\xmlonly <nonauthorized> \\endxmlonly \1 \\xmlonly </nonauthorized> \\endxmlonly <br/> \\xmlonly </redundant> \\endxmlonly"],
 [re.compile("\[HandleError(.*)\]"),
  r"[HandleError\1] /// \\xmlonly <handleerror> \\endxmlonly A kivételeket hibalapokkal jeleníti meg. <br/> \\xmlonly </handleerror> \\endxmlonly "],
 [re.compile("\[JQueryPartial(.*)\]"),
  r"[JQueryPartial\1] /// \\xmlonly <jquerypartial> \\endxmlonly JSON protokollt használó Ajax szolgáltatás <br/> \\xmlonly </jquerypartial> \\endxmlonly"],
 [re.compile("([a-zA-Z]*)EventLogger.Log(.*?)\((.*).$"),
  r"\1EventLogger.Log\2(\3 /// \\xmlonly<audit>\2(\3</audit>\\endxmlonly \\xmlonly <redundant> \\endxmlonly Naplózza a \2 eseményt (\1 eseményosztály; Casino.Web.Common.Event.Logger.\1EventLogger.Log\2 )<br/> \\xmlonly </redundant> \\endxmlonly"],
 [re.compile("bool [iI]sInputValid = (.*).$"),
  r"bool IsInputValid = (.*) /// \\xmlonly <redundant> \\endxmlonly Kontraktus: \\xmlonly </redundant><contract> \\endxmlonly \1 \\xmlonly </contract> \\endxmlonly "],
 [re.compile("InputValidationHelper.(.*)\((.*)\)(.*).$"),
  r"InputValidationHelper.\1(\2)\3 /// \\xmlonly <redundant> \\endxmlonly Kontraktus: \\xmlonly <contract>\\endxmlonly \1(\2)\\xmlonly </contract>\\endxmlonly <br>Hibaüzenet  \\xmlonly <error><cause>\\endxmlonly validációs hiba \\xmlonly</cause>\\endxmlonly esetén:\\xmlonly <value>\\endxmlonly StringIsNotValidException  \\xmlonly </value></error>\\endxmlonly<br/> \\xmlonly </redundant> \\endxmlonly"],
 [re.compile("InputVerificationHelper.(.*)\((.*)\)(;.*).$"),
  r"InputVerificationHelper.\1(\2)\3 /// \\xmlonly <redundant> \\endxmlonly Kontraktus: \\xmlonly <contract>\\endxmlonly \1(\2)\\xmlonly </contract>\\endxmlonly <br>Hibaüzenet  \\xmlonly <error><cause>\\endxmlonly validációs hiba \\xmlonly</cause>\\endxmlonly esetén:\\xmlonly <value>\\endxmlonly StringIsNotValidException  \\xmlonly </value></error>\\endxmlonly<br/> \\xmlonly </redundant> \\endxmlonly"],
 [re.compile("Util.GetUserCookie\(([^\.]*)\.(.*)Cookie(.*)\)(;.*).$"),
  r"Util.GetUserCookie(\1.\2Cookie\3)\4 /// \\xmlonly <cookie>\2\3</cookie> \\endxmlonly"],
 [re.compile("@logdef{(.*)}"),
  r"\xrefitem log \"Log\" \"Audit\" \1"],

]
#"logdef{1}=\xrefitem log \"Log\" \"Audit\" \1"

def transform(line):
  #if re1.search(line):
  for (pat,sub) in re2:
    if pat.search(line):
      return pat.sub(sub, line)
  return line

def sqlconvert():
	sql = SqlConverter(sys.argv[1])
	sql.run()

def csconvert():
	f = open(sys.argv[1])
#	g = open(sys.argv[1]+"out","w")
	line = f.readline()
	while line:
		line=transform(line)
		sys.stdout.write(line)
#		g.write(line)
		line = f.readline()
	f.close()
#	g.close()


if (len(sys.argv) < 2):
    print "No input file"
else:
	if sys.argv[1][-3:] == 'sql':
		sys.stderr.write("sql conversion for %s\n"%sys.argv[1])
		sqlconvert()
	else:
		sys.stderr.write("cs conversion for %s\n"%sys.argv[1])
		csconvert()

