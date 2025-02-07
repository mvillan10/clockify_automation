# Clockify Time Manager

Clockify Time Manager is a powerful automation tool designed to streamline your time tracking experience with Clockify. Instead of manually logging time entries, this tool allows you to fetch, delete, and add entries efficiently with minimal effort. Developed in PowerShell and executed via a batch file, it simplifies time tracking and ensures accurate logging of work hours.

## Features

- **Weekday Time Entry Automation** – Automatically adds work hours for weekdays (Monday to Friday) within the given date range, excluding weekends.
- **Avoids Overlapping Entries** – Checks for existing time entries within the specified date range and deletes them before adding new ones.
- **Last Run Date Tracking** – Stores the last entered date and uses it as the start date for the next execution.
- **Efficient Bulk Management** – Fetch, delete, and add multiple time entries seamlessly.
- **Easy Configuration** – Simple setup using an environment variables file.
- **User-Friendly Execution** – Run the script with a single command or batch file.

## Project Structure

```
ClockifyTimeManager/
│── .env                     # Stores environment variables (API keys, IDs, etc.)
│── ClockifyTimeManager.ps1   # Core script handling time entries
│── ClockifyTimeManagerEntry.ps1 # Script for user interaction
│── LastRunDate.txt           # Tracks the last execution date
│── runClockifyManager.bat    # Batch file to execute the entry script
│── sample.env                # Sample environment variables file
│── LICENSE                   # License information
│── README.md                 # Documentation (this file)
```

## Setup Guide

### 1. Clone the Repository

To get started, clone the repository using Git:

```sh
git clone https://github.com/mvillan10/clockify_automation.git
cd ClockifyTimeManager
```

### 2. Configure Environment Variables

Before running the script, configure your Clockify API credentials:

- Copy the sample environment file and rename it:

  ```sh
  cp sample.env .env
  ```

- Open `.env` and replace the placeholder values with your actual Clockify API key and IDs:

  ```ini
  API_KEY=your_api_key_here
  WORKSPACE_ID=your_workspace_id_here
  USER_ID=your_user_id_here
  PROJECT_ID=your_project_id_here
  TASK_ID=your_task_id_here
  ```

### 3. Run the Script

Execute the script using the provided batch file or via the command line:

```sh
./runClockifyManager.bat
```

Alternatively, you can run the PowerShell script directly:

```sh
powershell -ExecutionPolicy Bypass -File ClockifyTimeManagerEntry.ps1
```

## Usage Instructions

Upon execution, the script will prompt you to enter the date range:

- **Start Date** – Enter in `YYYY-MM-DD` format or press `Enter` to use the last recorded run date.
- **End Date** – Enter in `YYYY-MM-DD` format or press `Enter` to use today's date.

### Workflow:

1. **Load Environment Variables** – The script reads `.env` to retrieve API credentials and workspace details.
2. **Fetch Existing Entries** – It retrieves current time entries from Clockify within the specified range.
3. **Delete Entries** – If any existing entries are found, they are removed for a clean slate.
4. **Add New Entries** – New weekday time entries are generated based on the provided project and task IDs.

## Troubleshooting

- **Permission Errors**: Ensure you have the necessary execution permissions for PowerShell scripts.
- **API Issues**: Verify that your API key and workspace ID are correctly set in the `.env` file.
- **Date Format Issues**: Ensure dates are entered in the `YYYY-MM-DD` format.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

For any questions or contributions, feel free to open an issue or submit a pull request on GitHub!

