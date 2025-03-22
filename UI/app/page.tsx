import { getGatePassStats, getRecentGatePasses, type GatePass } from "@/lib/supabase";

export default async function Home() {
  try {
    console.log('Fetching data from Supabase...');
    const stats = await getGatePassStats();
    const recentPasses = await getRecentGatePasses();
    
    console.log('Stats:', stats);
    console.log('Recent passes:', recentPasses);

    if (!recentPasses || recentPasses.length === 0) {
      return (
        <div className="text-center py-10">
          <h2 className="text-2xl font-bold text-gray-900">Không có dữ liệu</h2>
          <p className="mt-1 text-sm text-gray-500">
            Kiểm tra kết nối Supabase hoặc tạo dữ liệu mẫu
          </p>
        </div>
      );
    }

    return (
      <div>
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900">Dashboard</h2>
          <p className="mt-1 text-sm text-gray-500">
            Tổng quan về hoạt động ra vào cổng
          </p>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {/* Thống kê */}
          <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
            <dt className="truncate text-sm font-medium text-gray-500">
              Tổng số phiếu hôm nay
            </dt>
            <dd className="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
              {stats.totalToday}
            </dd>
          </div>

          <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
            <dt className="truncate text-sm font-medium text-gray-500">
              Đang trong công ty
            </dt>
            <dd className="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
              {stats.active}
            </dd>
          </div>

          <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
            <dt className="truncate text-sm font-medium text-gray-500">
              Chờ duyệt
            </dt>
            <dd className="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
              {stats.pending}
            </dd>
          </div>

          <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
            <dt className="truncate text-sm font-medium text-gray-500">
              Đã hoàn thành hôm nay
            </dt>
            <dd className="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
              {stats.completedToday}
            </dd>
          </div>
        </div>

        <div className="mt-8">
          <h3 className="text-lg font-medium leading-6 text-gray-900">
            Phiếu vào cổng gần đây
          </h3>
          <div className="mt-4 overflow-hidden shadow ring-1 ring-black ring-opacity-5 sm:rounded-lg">
            <table className="min-w-full divide-y divide-gray-300">
              <thead className="bg-gray-50">
                <tr>
                  <th scope="col" className="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6">
                    Số phiếu
                  </th>
                  <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                    Người tạo
                  </th>
                  <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                    Phòng ban
                  </th>
                  <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                    Trạng thái
                  </th>
                  <th scope="col" className="relative py-3.5 pl-3 pr-4 sm:pr-6">
                    <span className="sr-only">Actions</span>
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 bg-white">
                {recentPasses.map((pass: GatePass) => (
                  <tr key={pass.id}>
                    <td className="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
                      {pass.pass_number}
                    </td>
                    <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                      {pass.creator?.full_name}
                    </td>
                    <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                      {pass.department}
                    </td>
                    <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                      <span className={`inline-flex rounded-full px-2 text-xs font-semibold leading-5 ${
                        pass.status === 'created' ? 'bg-yellow-100 text-yellow-800' :
                        pass.status === 'approved' ? 'bg-blue-100 text-blue-800' :
                        pass.status === 'checked_in' ? 'bg-green-100 text-green-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {pass.status === 'created' ? 'Chờ duyệt' :
                         pass.status === 'approved' ? 'Đã duyệt' :
                         pass.status === 'checked_in' ? 'Đang trong công ty' :
                         'Đã ra về'}
                      </span>
                    </td>
                    <td className="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
                      <a href={`/gate-pass/${pass.id}`} className="text-indigo-600 hover:text-indigo-900">
                        Chi tiết
                      </a>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    );
  } catch (error) {
    console.error('Error fetching data:', error);
    return (
      <div className="text-center py-10">
        <h2 className="text-2xl font-bold text-red-900">Lỗi kết nối</h2>
        <p className="mt-1 text-sm text-red-500">
          Không thể kết nối với Supabase. Chi tiết lỗi: {(error as Error).message}
        </p>
      </div>
    );
  }
}
