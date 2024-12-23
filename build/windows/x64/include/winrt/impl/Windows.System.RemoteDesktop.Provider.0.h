// WARNING: Please don't edit this file. It was generated by C++/WinRT v2.0.220418.1

#pragma once
#ifndef WINRT_Windows_System_RemoteDesktop_Provider_0_H
#define WINRT_Windows_System_RemoteDesktop_Provider_0_H
WINRT_EXPORT namespace winrt::Windows::Foundation
{
    struct Uri;
}
WINRT_EXPORT namespace winrt::Windows::UI
{
    struct WindowId;
}
WINRT_EXPORT namespace winrt::Windows::System::RemoteDesktop::Provider
{
    enum class RemoteDesktopConnectionStatus : int32_t
    {
        Connecting = 0,
        Connected = 1,
        UserInputNeeded = 2,
        Disconnected = 3,
    };
    struct IRemoteDesktopConnectionInfo;
    struct IRemoteDesktopConnectionInfoStatics;
    struct RemoteDesktopConnectionInfo;
}
namespace winrt::impl
{
    template <> struct category<winrt::Windows::System::RemoteDesktop::Provider::IRemoteDesktopConnectionInfo>{ using type = interface_category; };
    template <> struct category<winrt::Windows::System::RemoteDesktop::Provider::IRemoteDesktopConnectionInfoStatics>{ using type = interface_category; };
    template <> struct category<winrt::Windows::System::RemoteDesktop::Provider::RemoteDesktopConnectionInfo>{ using type = class_category; };
    template <> struct category<winrt::Windows::System::RemoteDesktop::Provider::RemoteDesktopConnectionStatus>{ using type = enum_category; };
    template <> inline constexpr auto& name_v<winrt::Windows::System::RemoteDesktop::Provider::RemoteDesktopConnectionInfo> = L"Windows.System.RemoteDesktop.Provider.RemoteDesktopConnectionInfo";
    template <> inline constexpr auto& name_v<winrt::Windows::System::RemoteDesktop::Provider::RemoteDesktopConnectionStatus> = L"Windows.System.RemoteDesktop.Provider.RemoteDesktopConnectionStatus";
    template <> inline constexpr auto& name_v<winrt::Windows::System::RemoteDesktop::Provider::IRemoteDesktopConnectionInfo> = L"Windows.System.RemoteDesktop.Provider.IRemoteDesktopConnectionInfo";
    template <> inline constexpr auto& name_v<winrt::Windows::System::RemoteDesktop::Provider::IRemoteDesktopConnectionInfoStatics> = L"Windows.System.RemoteDesktop.Provider.IRemoteDesktopConnectionInfoStatics";
    template <> inline constexpr guid guid_v<winrt::Windows::System::RemoteDesktop::Provider::IRemoteDesktopConnectionInfo>{ 0x886BDE2A,0x46AD,0x5A25,{ 0x93,0x48,0x03,0xE8,0x01,0xC7,0x85,0x75 } }; // 886BDE2A-46AD-5A25-9348-03E801C78575
    template <> inline constexpr guid guid_v<winrt::Windows::System::RemoteDesktop::Provider::IRemoteDesktopConnectionInfoStatics>{ 0x4A7DC5A1,0x3368,0x5A75,{ 0xBB,0x78,0x80,0x7D,0xF7,0xEB,0xC4,0x39 } }; // 4A7DC5A1-3368-5A75-BB78-807DF7EBC439
    template <> struct default_interface<winrt::Windows::System::RemoteDesktop::Provider::RemoteDesktopConnectionInfo>{ using type = winrt::Windows::System::RemoteDesktop::Provider::IRemoteDesktopConnectionInfo; };
    template <> struct abi<winrt::Windows::System::RemoteDesktop::Provider::IRemoteDesktopConnectionInfo>
    {
        struct __declspec(novtable) type : inspectable_abi
        {
            virtual int32_t __stdcall SetConnectionStatus(int32_t) noexcept = 0;
        };
    };
    template <> struct abi<winrt::Windows::System::RemoteDesktop::Provider::IRemoteDesktopConnectionInfoStatics>
    {
        struct __declspec(novtable) type : inspectable_abi
        {
            virtual int32_t __stdcall GetForLaunchUri(void*, struct struct_Windows_UI_WindowId, void**) noexcept = 0;
        };
    };
    template <typename D>
    struct consume_Windows_System_RemoteDesktop_Provider_IRemoteDesktopConnectionInfo
    {
        auto SetConnectionStatus(winrt::Windows::System::RemoteDesktop::Provider::RemoteDesktopConnectionStatus const& value) const;
    };
    template <> struct consume<winrt::Windows::System::RemoteDesktop::Provider::IRemoteDesktopConnectionInfo>
    {
        template <typename D> using type = consume_Windows_System_RemoteDesktop_Provider_IRemoteDesktopConnectionInfo<D>;
    };
    template <typename D>
    struct consume_Windows_System_RemoteDesktop_Provider_IRemoteDesktopConnectionInfoStatics
    {
        auto GetForLaunchUri(winrt::Windows::Foundation::Uri const& launchUri, winrt::Windows::UI::WindowId const& windowId) const;
    };
    template <> struct consume<winrt::Windows::System::RemoteDesktop::Provider::IRemoteDesktopConnectionInfoStatics>
    {
        template <typename D> using type = consume_Windows_System_RemoteDesktop_Provider_IRemoteDesktopConnectionInfoStatics<D>;
    };
}
#endif
