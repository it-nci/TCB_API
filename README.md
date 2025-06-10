# TCB_API

TCB 2025 is the web-based cancer registry of Thailand , hosted by National cancer Institute of Thailand
To facilitate data flow to TCB , we also provided the API to recieve data from any hosptial in Thailand.
- ขอใช้การส่งผ่านข้อมูลด้วย API [โหลดเอกสารได้ที่นี่](/2แบบฟอร์มขอใช้ระบบAPI.pdf)
- API document link :
  https://documenter.getpostman.com/view/27089148/2sAYdoG86Y
- Master data (Reference code) : [Master data code (for mapping)](/master_data) 
- โครงสร้าง view ที่แนะนำ
- ![structure](https://github.com/it-nci/TCB_API/blob/main/image/Screenshot%202025-04-27%20222109.jpg)
- [icd9cm ที่อาจใช้ดึงข้อมูลการรักษาทั้งผ่าตัด/เคมี/รังสี](/icd9cm).

## Linux
```bash
bash -c "$(curl -L https://raw.githubusercontent.com/it-nci/TCB_API/refs/heads/main/linux/install.sh)"
```