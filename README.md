# Career Readiness Advisor

A mobile app that compares an Information Systems student's courses with what
Saudi job postings ask for. It shows a readiness score, the missing skills ranked
by demand, and the courses that would close them. Department staff get a view of
the curriculum against the same postings. The app is in English and Arabic.

The readiness figures are estimates. The skill matcher behind them scored F1
0.504 against its 0.60 target, and the app says so beside the numbers.

The project has two parts, and **both must be running**:

| Part | Folder | Built with |
|---|---|---|
| Backend API | `backend/`, `skillgap/` | Python, FastAPI |
| Mobile app | `app/` | Flutter |

## What you need

- [Python 3.13](https://www.python.org/downloads/)
- [Flutter 3.47](https://docs.flutter.dev/get-started/install) or newer
- One of these to run the app on:
  - an Android emulator (Android Studio, with a standard API 35 or 36 image)
  - an Android phone
  - an iPhone or the iOS Simulator, which needs a Mac with Xcode
- About 5 GB of free disk space and an internet connection for the first setup

No account or API key is needed to run the app.

## 1. Get the code

```bash
git clone https://github.com/Azzam-alanazi/career-readiness-advisor.git
```

```bash
cd career-readiness-advisor
```


## 2. Start the backend

Run these from the `career-readiness-advisor` folder.

Create a virtual environment:

```bash
python -m venv .venv
```

Activate it on Windows:

```powershell
.venv\Scripts\Activate.ps1
```

Or on macOS or Linux:

```bash
source .venv/bin/activate
```

Install the dependencies:

```bash
python -m pip install -r backend/requirements.txt
```

Start the server, and leave this terminal open:

```bash
python -m uvicorn backend.main:app --port 8000
```

The first start is slow: it downloads the language model (about 1 GB) and reads
all the job postings. Later starts reuse the saved results and take moments.

It's ready when the terminal shows `Application startup complete`. To check, open
http://127.0.0.1:8000/health in a browser. You should see `"status":"ok"`.

## 3. Start the app

Open a **second terminal**, in the `career-readiness-advisor` folder:

```bash
cd app
```

```bash
flutter pub get
```

Then follow the option for your device.

### Android emulator or iOS Simulator

Start the emulator or simulator, then run:

```bash
flutter run
```

The app finds the backend by itself.

### A real phone

The phone needs your computer's address, because the backend runs on your
computer.

1. Put the phone and the computer on the same Wi-Fi network.
2. Find the computer's address. On Windows, run `ipconfig` and read the IPv4
   Address. On a Mac, run `ipconfig getifaddr en0`.
3. Stop the backend with Ctrl+C, and start it again so the network can reach it.
   Do this only on a network you trust:

   ```bash
   python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000
   ```

4. If Windows Firewall asks about Python, allow it on private networks.
5. On the phone, open `http://YOUR-ADDRESS:8000/health` in the browser. If you
   see `"status":"ok"`, the phone can reach the backend.
6. Plug in the phone and run the app, with your address in place of the example:

   ```bash
   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000
   ```

On an Android phone, turn on USB debugging first. An iPhone also needs a Mac and
code signing: see [On an iPhone](app/README.md#on-an-iphone).

## Using the app

1. On the **Student** tab, choose up to three target careers and tick the courses
   you've completed.
2. Optionally add skills you've learned outside your courses, then tap **See my
   readiness**.
3. From the home screen, open your full readiness, plan courses, or change the
   language and your profile in Settings.

The **Department** tab shows the curriculum against the job postings.

## If something goes wrong

| Problem | Fix |
|---|---|
| The app says it can't reach the server | Check the backend terminal is still running. On a real phone, repeat the `/health` check in step 5 and check the address you passed to `flutter run` |
| The address changed, on a new network for example | Run `flutter run` again with the new address; it is built into the app |
| A black screen on the Android emulator | Use a standard API 35 or 36 x86_64 image, not the Android 17 16 KB-page image |
| `Activate.ps1` is blocked on Windows | Run `.venv\Scripts\activate.bat` from Command Prompt instead |
| Installing or starting the backend fails | Check `python --version` shows 3.13 and that the virtual environment is active |
| `flutter run` finds no device | Run `flutter devices`, and start an emulator or reconnect the phone |

## Application deployment method

The code is hosted on GitHub. The app is deployed locally, not on a public
server: the backend runs on your own computer, and the app is installed on a
phone or emulator that can reach it.

| Part | How it is deployed |
|---|---|
| Source code | This GitHub repository |
| Backend API | Python process on a local computer, served by Uvicorn on port 8000 (step 2) |
| Student data | Saved only on the phone; the server stores nothing about students |
| Android app | Installed from the computer with `flutter run`, or from an APK file (below) |
| iPhone app | Built on a Mac with Xcode: see [On an iPhone](app/README.md#on-an-iphone) |

To build an Android APK file, run this from the `app` folder, with your
computer's address in place of the example:

```bash
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.1.20:8000
```

The file is written to `app/build/app/outputs/flutter-apk/app-debug.apk`. Copy it
to an Android phone and open it to install. It must be a debug build, because
Android release builds refuse the plain HTTP connection the local backend uses.
The address is built into the file, so a different network needs a new build.

## Resource folders

| Folder | What it holds |
|---|---|
| `app/` | The Flutter mobile app |
| `app/lib/` | App source code: `core/` for shared code, `features/` for each screen area, `l10n/` for English and Arabic text |
| `app/test/` | App tests |
| `app/android/`, `app/ios/` | Android and iOS project files |
| `backend/` | The FastAPI service the app talks to, and `tests/` for it |
| `skillgap/` | The skill-matching engine, the 91-skill taxonomy (`taxonomy.json`), the matching settings (`config.json`), and the course data (`labeled_courses.csv`, `online_courses.csv`) |
| `skillgap/archive/` | Earlier data, kept so past results can be reproduced |
| `test/` | The job postings (`labeled_postings.csv`) and the scripts that collected and labelled them |
| `test/raw_responses/` | Saved job-search API responses, kept as evidence for the sampling findings |
| `test/holdout/`, `test/archive/` | Labels and samples from the validation work |
| `docs/analysis-design/` | The analysis and design document, with the UML, database and ER diagrams (`png/`, `svg/`) and the scripts that draw them (`src/`) |

## Run the tests

Backend, from the `career-readiness-advisor` folder:

```bash
python -m pytest
```

App, from the `app` folder:

```bash
flutter test
```

## More documentation

- [App](app/README.md): design, structure and tests
- [Backend](backend/README.md): API endpoints and how the service works
- [Engine and data](skillgap/README.md): the matcher, taxonomy and data files
- [Project specification](CAREER_PROJECT_SPEC.md): scope, decisions and measured results
- [Analysis and design](docs/analysis-design/README.md): UML, database and ER diagrams
